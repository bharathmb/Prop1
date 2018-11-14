$(document).ready(function(){	
  
  $("#downloadbutton").on("click", function(){
    
	alert("inside Ensemble Model....");
	    $("#downloadbutton").attr("disabled", "disabled");  
	  
	  $("#status2").text("Scoring in progress...");
	
	//Check which model is selected
	var dvname=$("#dvname").val()
	
	var oos_path= $("#uploadFile2")[0].files[0];
	
	var isChecked=""
	
	if($('#select-1').prop('checked')==true)
		{
		 isChecked="select-1"
		} else if($('#select-2').prop('checked')==true)
		{
		 isChecked="select-2"
		} else if($('#select-3').prop('checked')==true)
		{
		 isChecked="select-3"
		} else if($('#select-4').prop('checked')==true)
		{
		 isChecked="select-4"
		} else if($('#select-5').prop('checked')==true)
		{
		 isChecked="select-5"
		} else if($('#select-6').prop('checked')==true)
		{
		 isChecked="select-6"
		}
		else if($('#select-7').prop('checked')==true)
		{
		 isChecked="select-7"
		}
		
		//alert(isChecked);

		
    //perform the request
    var req = ocpu.call("scoring_module", {
	    "oos_path":oos_path, "DV" : dvname, "model_selection" :  isChecked
    }, function(session){
		$("#status2").text("Hurray! Scoring Completed... Find the results in c:/opencpuip_app/scored_dataset.csv");	
		//get results and display
		alert("Scoring Done");
		
    });
    
    //if R returns an error, alert the error message
    req.fail(function(){
      alert("Server error: " + req.responseText);
    });
    
    //after request complete, re-enable the button 
    req.always(function(){
      $("#downloadbutton").removeAttr("disabled")
    });   

  });

  });

