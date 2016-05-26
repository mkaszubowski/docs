import "phoenix_html";
import { Socket } from "phoenix" ;

import { setSelectionRange } from './setSelectionRange';

class App {
  static init() {
    let socket = new Socket("/socket")
    let documentNotSaved = false;

    socket.connect()
    socket.onClose( e => console.log("Closed connection") )

    let selectionStart, selectionEnd;

    const id = $('#document-id').val();

    var channel = socket.channel("docs:test", {id: id})
    channel.join()
      .receive( "error", () => console.log("Connection error") )
      .receive( "ok",    () => console.log("Connected") )

    $('#text').on('keyup', e => {
      if ((e.keyCode >= 32 && e.keyCode <= 126) || e.keyCode == 13 || e.keyCode == 8) {
        documentNotSaved = true;

        selectionStart = $('#text')[0].selectionStart;
        selectionEnd = $('#text')[0].selectionEnd;

        channel.push("new:content", {
          content: $('#text').val(),
          id: id,
        })
      }
    })

    channel.on( "new:content", msg => {
      $('#text').val(msg.content);

      setSelectionRange($('#text')[0], selectionStart, selectionEnd);
    });
    channel.on( "replace:expression", msg => {
      const expr = '{{' + msg["expression"] + '}}'
      const value = msg["value"][0]

      let content = $("#text").val().replace(expr, value)

      $('#text').val(content);
      setSelectionRange($('#text')[0], selectionStart, selectionEnd);
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
