// Copyright © 2011-2018 MUSC Foundation for Research Development~
// All rights reserved.~

// Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

// 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

// 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
// disclaimer in the documentation and/or other materials provided with the distribution.~

// 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
// derived from this software without specific prior written permission.~

// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
// BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
// SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
// TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

function validateFiles(inputFile) {
  var allowedExtension = ["xml", "XML"];

  var extName;
  var extError = false;

  $.each(inputFile.files, function() {
    extName = this.name.split('.').pop();
    if ($.inArray(extName, allowedExtension) == -1) {extError=true;};
  });

  if (extError) {
    $('.klok-submit-button').each(function(key, value) {
      if ($(value).hasClass('disabled')) {
      } else {
        $(value).addClass('disabled');
      }
    })
    swal("Oops", "Only .xml files are allowed", "error");
    $(inputFile).val('');
  } else {
    $('.klok-submit-button').each(function(key, value) {
      $(value).removeClass('disabled');
    })
  }
}
$(function() {
  $('.spinner').hide();
  // We can attach the `fileselect` event to all file inputs on the page
  $(document).on('change', ':file', function() {
    $('#file-display').val($(this).val().replace(/^.*[\\\/]/, ''));
  });

  $(document).on('click', '.proof-report', function(){
    $('.proof-report').button('loading')
  });

  $(document).on('click', '.import-klok-data', function(){
    $('.import-klok-data').button('loading')
  });

  $(document).ajaxStart(function(){
    $('.spinner').show();
  });

  $(document).ajaxStop(function(){
    $('.spinner').hide();
    $('.import-klok-data').button('complete')
    $('.proof-report').button('complete')
  });
});
