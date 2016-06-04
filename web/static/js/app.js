import "phoenix_html";
import { Socket } from "phoenix";
import Quill from 'quill';

class App {
  static init() {
    let socket = new Socket("/socket")
    let documentNotSaved = false;

    var quill = new Quill('#editor', {
      theme: 'snow',
    });
    quill.addModule('toolbar', { container: '#toolbar' });
    let cursors = quill.addModule('multi-cursor', {
      timeout: 10000
    });

    socket.connect()
    socket.onClose( e => console.log("Closed connection") )

    let selectionStart, selectionEnd;

    const id = $('#document-id').val();
    const userName = $('#user-name').val();

    var channel = socket.channel("docs:test", {id: id})
    channel.join()
      .receive( "error", () => console.log("Connection error") )
      .receive( "ok",    () => console.log("Connected") )

    quill.on('text-change', (delta, source) => {
      if (source === 'user') {
        documentNotSaved = true;

        selectionStart = quill.getSelection().start;
        selectionEnd = quill.getSelection().end;

        channel.push("new:content", {
          content: quill.getHTML(),
          id: id,
          position: selectionEnd,
          user_name: userName,
        })
      }
    })

    channel.on( "new:content", msg => {
      quill.setHTML(msg['content'])

      if (msg['user_name'] != userName) {
        cursors.setCursor(
          msg['user_name'],
          msg['position'],
          msg['user_name'],
          'rgb(255, 0, 255)'
        );
      }
      quill.setSelection(selectionStart, selectionEnd);
    });
    channel.on( "replace:expression", msg => {
      const expr = '{{' + msg["expression"] + '}}'
      const value = msg["value"][0]

      let content = $("#text").val().replace(expr, value)

      $('#editor').val(content);
      quill.setSelection(selectionStart, selectionEnd);
    });
    channel.on("document:saved", msg => {
      documentNotSaved = false;
      $('.document .notification').addClass('visible');
      setTimeout(() => {
        $('.document .notification').removeClass('visible');
      }, 2500);

    });

    window.onbeforeunload = () => {
      if (documentNotSaved) {
        return "The changes not saved yet";
      }
    }
  }
}

$( () => App.init() )

export default App
