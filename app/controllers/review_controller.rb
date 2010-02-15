class ReviewController < ApplicationController

  before_filter :fetch_classifier

  after_filter :store_classifier
  
  def fetch_classifier
    @classifier = if session[:classifier]
      b = Bishop::Bayes.new
      b.load_data session[:classifier], Marshal
      b
    else
      init_classifier
    end
  end

  def store_classifier
    session[:classifier] = @classifier.export Marshal
  end

  def init_classifier
    returning(Bishop::Bayes.new) do |classifier|
      @user.entries.categorized.find(:all, :include => :ledgers).each do |entry|
        entry.remote_ledgers.each do |ledger|
          train(ledger, entry, classifier) unless entry.transfer?
        end
      end
    end
  end

  def classification_string(entry)
    [entry.memo, entry.local_ledgers.map(&:name).join(" ")].join(" ")
  end

  # Takes an entry, and returns a suggested category.
  def suggest(entry)
    lookup = classification_string(entry)

    results = @classifier.guess(lookup)

    xx = results.map{|lid, score| [@user.ledgers.find(lid).name, score]}

    puts "Guessed #{xx.inspect} for #{classification_string(entry)}"

    ledger_id = (x=results.max{|e,ee| e.last <=> ee.last}) && x && x[0]

    ledger_id ? @user.ledgers.find(ledger_id) : @user.unknown
  end

  def train(ledger, entry, classifier = @classifier)
    classifier.train ledger.id, c=classification_string(entry)
    puts "Trained #{c.inspect} to #{ledger.name}"
  end

  def index
    @pairs = (@user.expenses + @user.categories).sort_by(&:name).in_groups_of(2, false)
  end

  def next
    @entry = @user.entries.uncategorized.find(:first, :include => {:splits => :ledger}, :order => "posted DESC")
    @ledger = suggest(@entry)

    render :update do |page|
      page.replace_html 'entry', :partial => 'entry'
      page.replace_html 'suggestion', :partial => 'suggestion'
      page.call 'updateButtonCallbacks'
      page.call '$("#entry_id").attr', :value, @entry.id
      page.call 'revealEntry'
    end
  end

  def update
    entry = @user.entries.find(params[:entry_id])
    ledger = @user.ledgers.find(params[:ledger_id])

    Entry.transaction do
      entry.remote_splits.each do |split|
        split.ledger = ledger
        split.save!
      end

      entry.update_attribute :uncategorized, false
    end

    train(ledger, entry) unless ledger.unknown?

    puts "Moved entry #{entry.memo} to ledger #{ledger.name}"

    redirect_to :action => :next
  end

end
