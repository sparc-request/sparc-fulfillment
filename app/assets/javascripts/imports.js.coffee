# Copyright © 2011-2020 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

$ ->
  # We can attach the `fileselect` event to all file inputs on the page
  $(document).on 'change', ':file', ->
    $('#file-display').val $(this).val().replace(/^.*[\\\/]/, '')

  $(document).on 'click', '.klok-submit-button', ->
    button = $(this)
    button.val(button.data('loading-text'))
    $('.fa-sync').removeClass('d-none')

  $(document).ajaxStop ->
    $('.fa-sync').addClass('d-none')
    $('.klok-submit-button').each ->
      button = $(this)
      button.val(button.data('complete-text'))

  $(document).on 'change', '.file-input.validated', ->
    allowedExtensions = ['xml', 'XML']
    extensionUsed = $(this).val().split('.').pop()

    if allowedExtensions.includes(extensionUsed)
      $('.klok-submit-button').each ->
        $(this).prop('disabled', false)
    else
      Swal.fire(
        title: "Oops"
        text: "Only .xml files are allowed"
        icon: "error"
        showCancelButton: false
      ).then (result) ->
        if result.isConfirmed
          $('.file-input.validated').val('')
          $('#file-display').val('')

          $('.klok-submit-button').each ->
            $(this).prop('disabled', true)
