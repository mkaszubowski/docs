import "phoenix_html";
import { Socket } from "phoenix";
import Quill from 'quill';

class App {
  static initDocument() {
    let socket = new Socket("/socket")

    var quill = new Quill('#editor', {
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
    const userId = $('#user-id').val();

    let channel = socket.channel("docs:" + id, {
      user_name: userName,
      user_id: userId
    });

    channel.join()
      .receive( "error", () => console.log("Connection error") )
      .receive( "ok",    () => console.log("Connected") )

    quill.on('text-change', (delta, source) => {
      if (source === 'user') {

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
      if (msg["document_id"] != id) { return; }

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
    channel.on( "update:users", msg => {
      if (msg["document_id"] != id) { return; }

      let list = '';
      msg.users.filter(user => user.id != userId).map((user) => {
        list += `<p class='user-${user.id}'>${user.name}</p>`;
      })
      $('#viewing-users .list').html(list);
    });


    channel.on( "replace:expression", msg => {
      const expr = '{{' + msg["expression"] + '}}'
      const value = msg["value"][0];
      const positionOffset = expr.length - value.toString().length;

      const content = quill.getHTML().replace(expr, value);

      quill.setHTML(content)
      quill.setSelection(
        selectionStart - positionOffset,
        selectionEnd - positionOffset);
    });

    channel.on("document:saved", msg => {
      $('.document .notification').addClass('visible');
      setTimeout(() => {
        $('.document .notification').removeClass('visible');
      }, 2500);

    });
  }
}

$( () => {
  if ($('#editor').length > 0) {
    App.initDocument();
  }
})

export default App
