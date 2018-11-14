$(document).ready(function(){
  	
		
  
  $("#submitbutton").on("click", function(){
    
	alert("inside up plot script....");

	
	    //var nfield = parseInt($("#nfield").val());
        //var distfield = $("#distfield").val();
        nfield=1000
	 distfield="normal"
        //create the plot area on the plotdiv element
	  alert("plotting");
                var req = $("#plotdiv1").rplot("randomplot", {
          n : nfield,
          dist : distfield
        })

        //if R returns an error, alert the error message
        req.fail(function(){
          alert("Server error: " + req.responseText);
        });
        
        //after request complete, re-enable the button 
        req.always(function(){
          $("#submitbutton").removeAttr("disabled")
        });

  });


  });

