export function addEventToProductFormButtons() {
    document.getElementById("form-save-publish-btn").onclick = function() {
        var form = document.getElementsByTagName("form")[0];
        document.getElementById("form-state").value = "active";
        document.getElementById("publish_redirection").value = true;
        document.getElementById("form-save-publish-btn").disabled = true;
        document.getElementById("form-save-btn").disabled = true;
        form.submit();
    };
  }