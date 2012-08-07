class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def session_def(var, sess, key)
#p 'session_def'
#p var[key]
#p sess[key]
    if var[key] == nil && sess[key] != nil
#p 'setting'
      var[key] = sess[key]
    end
  end

  def index

    # find unique ratings already in the database
    @all_ratings = Movie.find(:all, :select => "distinct rating", :order => :rating).collect { |movie| movie.rating }

    # prepare checked states for each rating
    @checks = Hash.new
    @all_ratings.each { |rating| @checks.store(rating, false) }

    # ^^^ ideally the sort functionality would protect against xss attacks via URL parameter
    # ^^^ move into method of Movie

    # default to session values if they're missing
    session_def(params, session, :sort)
    session_def(params, session, :ratings)

    if params[:sort] == nil then
      @order = "id"
    else
      @order = params[:sort]
    end

    if params[:ratings] == nil then
      @conditions = "1 = 1"
    else
      @conditions = "rating in ("
      params[:ratings].each_key { |rating|
        @conditions = @conditions + "'" + rating + "',"
        @checks[rating] = true
      }
      @conditions = @conditions + "'-')"
    end

    # select the movies constrained by sorting and filtering
    @movies = Movie.find(:all, :order => @order, :conditions => @conditions)

    # save session values for next iteration
    session[:sort] = params[:sort]
    session[:ratings] = params[:ratings]

  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
