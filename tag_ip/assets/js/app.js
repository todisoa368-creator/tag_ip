// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import {hooks as colocatedHooks} from "phoenix-colocated/tag_ip"
import topbar from "../vendor/topbar"

// 1. Déclaration des Hooks personnalisés
let Hooks = {
  ...colocatedHooks // On garde tes hooks existants (comme le Wizard ou autres)
}

// 2. Ajout du Hook pour la gestion des profils de montage
Hooks.ProfilMontageIndex = {
  mounted() {
    const calcBtn = document.getElementById('calc-btn');
    
    if (calcBtn) {
      calcBtn.addEventListener('click', () => {
        // Récupération des valeurs des sélecteurs
        const profilSelect = document.getElementById('profil-select');
        const modeleSelect = document.getElementById('modele-select');

        if (profilSelect && modeleSelect) {
          // Envoi de l'événement au serveur Elixir (monitor_project)
          this.pushEvent('calculer_compatibilite', {
            profil_id: profilSelect.value,
            modele_id: modeleSelect.value
          });
        }
      });
    }
  }
}

// 3. Configuration de la LiveSocket
const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: Hooks, // On utilise l'objet Hooks qui contient tout
})

// 4. Personnalisation de la barre de progression (Bleu TAG-IP)
topbar.config({barColors: {0: "#2563eb"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// Connexion
liveSocket.connect()

// Exposer la liveSocket pour le debug
window.liveSocket = liveSocket

// Configuration du Live Reload (Développement)
if (process.env.NODE_ENV === "development") {
  window.addEventListener("phx:live_reload:attached", ({detail: reloader}) => {
    reloader.enableServerLogs()
    let keyDown
    window.addEventListener("keydown", e => keyDown = e.key)
    window.addEventListener("keyup", _e => keyDown = null)
    window.addEventListener("click", e => {
      if(keyDown === "c"){
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtCaller(e.target)
      } else if(keyDown === "d"){
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtDef(e.target)
      }
    }, true)
    window.liveReloader = reloader
  })
}