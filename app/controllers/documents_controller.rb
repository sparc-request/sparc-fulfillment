class DocumentsController < ApplicationController

  respond_to :json, :html

  before_action :find_documentable, only: [:index]

  def index
    @documents = @documentable.documents
    @documentable_id = document_params[:documentable_id]
    @documentable_type = document_params[:documentable_type]
    @documentable_sym = @documentable_type.downcase.to_sym
  end

  def new
    @document = Document.new(document_params)
  end

  def create
    @document = Document.new(document_params)
    @document.doc = params[:document][:document]
    if @document.valid?
      @document.save
      flash[:success] = t(:documents)[:flash_messages][:created]
    else
      @errors = @document.errors
    end
  end

  private

  def document_params
    params.require(:document).permit(:documentable_type, :documentable_id)
  end

  def find_documentable
    @documentable = params[:document][:documentable_type].constantize.find params[:document][:documentable_id]
  end
end
