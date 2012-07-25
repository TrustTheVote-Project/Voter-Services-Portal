class VoterCardsController < ApplicationController

  # shows the voter card
  def show
    @registration = current_registration
    respond_to do |f|
      f.pdf do
        # Doing it in such a weird way because of someone stealing render / render_to_string method from wicked_pdf
        render text: WickedPdf.new.pdf_from_string(
          render_to_string(template: 'voter_cards/show', pdf: 'voter_card.pdf', layout: 'voter_card_pdf'),
          margin: { top: 5, right: 5, bottom: 5, left: 5 },
          orientation: 'Landscape' )
      end
    end

  end

end
