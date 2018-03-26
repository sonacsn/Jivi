export default function run_demo(root, channel) {
  var games=[];
  channel.join()
         .receive("ok", resp => { games=resp; render_list(games);console.log("Joined successfully", resp) })
         .receive("error", resp => { console.log("Unable to join", resp) });
  }

function render_list(obj){
  let games = obj.games;
  let sel = document.getElementById("sel");
  let fragment = document.createDocumentFragment();
  let emptyOp = document.createElement('option');
  emptyOp.innerHTML = "Select a game";
  emptyOp.value = "";
  fragment.appendChild(emptyOp);
  
  games.forEach(function(game, index) {
    var opt = document.createElement('option');
    opt.innerHTML = game;
    opt.value = game;
    fragment.appendChild(opt);
 });

  sel.appendChild(fragment);
}
