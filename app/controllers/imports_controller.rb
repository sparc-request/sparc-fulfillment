# Copyright © 2011-2018 MUSC Foundation for Research Development~
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

class ImportsController < ApplicationController

  def index
    @imports = Import.all
    respond_to do |format|
      format.html
      format.json
    end
  end

  def new
    @import = Import.new
    respond_to do |format|
      format.js
    end
  end

  def create
    import = Import.create(import_params)
    respond_to do |format|
      if import.save
        import.update_attribute(:title, determine_if_proof_report ? I18n.t('imports.proof_report_submit') : I18n.t('imports.klok_report_submit'))
        begin
          log_file, valid = import.generate(import.xml_file, determine_if_proof_report)
          import.update_attribute(:file, File.open(log_file))
          @valid = valid
          if @valid
            format.js
            format.html { redirect_to imports_path }
          else
            import.destroy
            format.js
          end
        rescue Exception => e
          import.destroy # remove the import since it has an error
          format.js { render js: "swal('Klok Import Error', \"#{e.message}\", 'error');" }
          format.html { render :new }
        end
      end
    end
  end

  private

  def determine_if_proof_report
    if params[:commit] == I18n.t('imports.proof_report_submit')
      true
    else
      false
    end
  end

  def import_params
    params.require(:import).permit(:xml_file, :title, :file)
  end
end

