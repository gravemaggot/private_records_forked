
// On Document load events: input masks

$(function(){

    position_type = ""
    if(document.getElementById('is_worker')){
        position_type = "worker"
    }

    // Phone mask
    $("#candidate_phone").mask("+375 (99) 999-99-99")
    
    // Image content
    imageElement = document.getElementById("image")
    if (imageElement && imageElement.files.length > 0){
        handleFiles(imageElement.files)
    }

    // Fill tables candidate's data
    contentElement = document.getElementById('relatives_content')
    if (contentElement){ fill_relatives_content(contentElement) }

    contentElement = document.getElementById('education_content')
    if (contentElement){ fill_education_content(contentElement, position_type) }

    contentElement = document.getElementById('extra_content')
    if (contentElement){ fill_extra_content(contentElement, position_type) }

    contentElement = document.getElementById('language_content')
    if (contentElement){ fill_language_content(contentElement) }
    
    contentElement = document.getElementById('experience_content')
    if (contentElement){fill_experience_content(contentElement, position_type)} 

    contentElement = document.getElementById('reccomenders_content')
    if (contentElement){ fill_reccomenders_content(contentElement) }
    
    // Validations
    validate_fields = document.getElementById("validate_fields")
    add_validation_tags(validate_fields)  
    switch_pills_on_last_field_and_focus(validate_fields)  

    // Delete button
    $(document).on("click", ".delete", function(){
        $(this).parents("tr").remove();
    });
    
    // Consent personal data
    modalElement = document.getElementById('consentModal')
    if (modalElement && !(document.getElementById("candidate_data_verification").value == "true")) {$('#consentModal').modal()}
});  
