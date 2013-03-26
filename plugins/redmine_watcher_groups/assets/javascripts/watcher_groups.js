function checkWatcher(id, value) {
  var watchers_checkboxes = document.getElementsByName("issue[watcher_user_ids][]");
  for(var i=0; i<watchers_checkboxes.length; i++) {
    if(id == watchers_checkboxes[i].value) {
        watchers_checkboxes[i].checked = value;
    }
  }
}

function checkWatchers(ids, value) {
  for(var i=0; i<ids.length; i++) {
    checkWatcher(parseInt(ids[i]), value);
  }
}
