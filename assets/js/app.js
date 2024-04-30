// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"
import Sortable from "../vendor/sortable"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

// Sortable
let Hooks = {};

// Contains Hook for drag and drop functionality.
Hooks.Sortable = {
  mounted() {
    let group = this.el.dataset.group
    let sorter = new Sortable(this.el, {
      group: group ? group : undefined,
      animation: 50,
      delay: 50,
      dragClass: "drag-item",
      ghostClass: "drag-ghost",
      forceFallback: true,
      onEnd: e => {
        let params = {old: e.oldIndex, new: e.newIndex, to: e.to.dataset, ...e.item.dataset}

        this.pushEventTo(this.el, "reposition", params)
      }
    })
  }
}

// Highlights path of available moves.
Hooks.Highlight = {
  mounted() {    
    pushEvent = () => this.pushEventTo(this.el, "highlight", this.el.id)
    throttle = _.throttle(pushEvent, 200)
    this.el.addEventListener("mousedown", throttle)
    this.el.addEventListener("mouseup", e => {
      let squares = document.querySelectorAll("[data-group='squares']")

      squares.forEach(square => {
        square.classList.remove("!bg-violet-300")
      });
    })

    this.handleEvent(`highlight_moves_${this.el.parentNode.id}`, moves_list => {
      moves_list["available_moves"].forEach(location => {
        let move = document.querySelector(`[id='[${location}]']`)

        move.classList.add("!bg-violet-300")
      });
    })
  }
}

let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}, hooks: Hooks})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()
// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

