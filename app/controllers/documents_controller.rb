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

class DocumentsController < ApplicationController
  layout nil

  before_action :find_document, only: [:show, :destroy]
  before_action :authorize_document_access, only: [:show]
  before_action :validate_presence_of_upload, only: [:create]

  def index
    respond_to do |format|
      format.html { render }
      format.js {
        find_documentable

        @documents = @documentable.documents
        @documentable_id = document_params[:documentable_id]
        @documentable_type = document_params[:documentable_type]
        @documentable_sym = @documentable_type.downcase.to_sym
      }
      format.json {
        @documents = find_documentable.documents.order("CREATED_AT DESC")
      }
    end
  end

  def show
    respond_to do |format|
      format.html {
        mark_document_as_accessed
        send_data File.read(@document.path),
          type: @document.content_type,
          disposition: "attachment; filename=#{@document.original_filename.gsub(' ', '_')}"
      }
      format.json {
        render json: { document: { state: @document.state, document_id: @document.id, documentable_type: @document.documentable_type } }
      }
    end
  end

  def new
    respond_to do |format|
      format.js {
        @document = Document.new(document_params)
      }
    end
  end

  def create
    respond_to do |format|
      format.js {
        @document = Document.create(document_params.merge!(original_filename: params[:document][:document].original_filename,
                                                          title: params[:document][:document].original_filename,
                                                          content_type: params[:document][:document].content_type,
                                                          state: "Completed"))

        create_document_file

        flash.now[:success] = t(:documents)[:flash_messages][:created]
      }
    end
  end

  def edit
    respond_to do |format|
      format.js {
        @document = Document.find(params[:id])
      }
    end
  end

  def update
    # only allow title to be updated
    @document = Document.find(params[:id])
    @document.title = params[:document][:title]
    if @document.valid?
      @document.save
      flash.now[:success] = t(:documents)[:flash_messages][:updated]
    else
      @errors = @document.errors
    end
  end

  def destroy
    respond_to do |format|
      format.js {        
        mark_document_as_accessed if @document.last_accessed_at.nil?
        @document.destroy

        flash[:alert] = t(:documents)[:flash_messages][:removed]
      }
    end
  end

  private

  def validate_presence_of_upload
    unless params[:document][:document].present?
      @error = t(:documents)[:flash_messages][:no_file_chosen]

      render
    end
  end

  def create_document_file
    uploaded_io = params[:document][:document]

    File.open(@document.path, 'wb') do |file|
      file.write(uploaded_io.read)
    end
  end

  def find_documentable
    if params[:document].present? && (params[:document][:documentable_id].present? && params[:document][:documentable_type].present?)
      id    = params[:document][:documentable_id]
      type  = params[:document][:documentable_type]
    else
      id    = current_identity.id
      type  = 'Identity'
    end

    @documentable ||= type.constantize.find id
  end

  def find_document
    @document = Document.find(params[:id])
  end

  def authorize_document_access
    head :ok unless @document.accessible_by?(current_identity)
  end

  def mark_document_as_accessed
    update_unaccessed_documents_counter(@document.documentable_type)

    @document.update_attributes last_accessed_at: Time.current
  end

  def update_unaccessed_documents_counter documentable_type
    if !@document.downloaded?
      case documentable_type
        when 'Protocol'
          protocol = Protocol.find(@document.documentable_id)
          protocol.document_counter_updated = true
          protocol.update_attributes(unaccessed_documents_count: (protocol.unaccessed_documents_count - 1))
        when 'Identity'
          current_identity.update_counter :unaccessed_documents, -1
      end
    end
  end

  def document_params
    params.require(:document).permit(:documentable_type, :documentable_id, :title)
  end
end
