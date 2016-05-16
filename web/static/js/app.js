import {Socket} from "phoenix" ;

class App {
  static init() {
    let socket = new Socket("/socket")
    socket.connect()
    socket.onClose( e => console.log("Closed connection") )

    var channel = socket.channel("docs:test", {})
    channel.join()
      .receive( "error", () => console.log("Connection error") )
      .receive( "ok",    () => console.log("Connected") )

    $('#text').on('keyup', e => {
      channel.push("new:content", {
        content: $('#text').val(),
      })
    })

    channel.on( "new:content", msg => {
      console.log(msg)
      $('#text').val(msg.content);
    })
  }
}

$( () => App.init() )

export default App
