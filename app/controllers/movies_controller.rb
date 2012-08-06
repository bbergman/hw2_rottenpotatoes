class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    # find unique ratings already in the database
    @all_ratings = Movie.find(:all, :select => "distinct rating", :order => :rating).collect { |movie| movie.rating }

    # ^^^ ideally the sort functionality would protect against xss attacks via URL parameter
    # ^^^ move into method of Movie

    @checks = { 'G' => false, 'PG' => false, 'PG-13' => false, 'R' => false }

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

    @movies = Movie.find(:all, :order => @order, :conditions => @conditions)
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
