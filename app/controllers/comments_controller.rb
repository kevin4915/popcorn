class CommentsController < ApplicationController
  def create
    @historic = Historic.find(params[:historic_id])
    @comment = @historic.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to community_path, notice: "Commentaire ajouté !"
    else
      redirect_to community_path, alert: "Erreur lors de l'ajout."
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end
end
