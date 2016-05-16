import { Socket } from "phoenix" ;

import { setSelectionRange } from './setSelectionRange';

class App {
  static init() {
    let socket = new Socket("/socket")
    socket.connect()
    socket.onClose( e => console.log("Closed connection") )

    let carretPosition = null;

    var channel = socket.channel("docs:test", {})
    channel.join()
      .receive( "error", () => console.log("Connection error") )
      .receive( "ok",    () => console.log("Connected") )

    $('#text').on('keyup', e => {
      if ((e.keyCode >= 32 && e.keyCode <= 126) || e.keyCode == 13) {
        carretPosition = $('#text')[0].selectionStart;

        channel.push("new:content", {
          content: $('#text').val(),
        })
      }
    })

    channel.on( "new:content", msg => {
      $('#text').val(msg.content);

      setSelectionRange($('#text')[0], carretPosition, carretPosition);
    })
  }
}

$( () => App.init() )

export default App
