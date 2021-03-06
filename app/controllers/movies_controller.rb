class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @movies = Movie.all
    @all_ratings = Movie.all_ratings
    check_consistency()
    @selected_rating = (params[:ratings] || Hash[@all_ratings.product([1])]).keys

     sort = params[:sort] || session[:sort]
    case sort
    when 'title'
      ordering,@title = {:order => :title}, 'bg-warning hilite'
    when 'release_date'
      ordering,@release_date = {:order => :release_date}, 'bg-warning hilite'
    end
    
    
   @movies = Movie.where(rating: @selected_rating).order(params[:sort])
       
  end
  
  def check_consistency
    # Session
    [:ratings, :sort].each {|key|
      if params[key] && (session[key].nil? || (session[key] != params[key]))
        session[key] = params[key]
      end
    }
    # Params
    if (session[:sort] && params[:sort].nil?) || (session[:ratings] && params[:ratings].nil?)
        redirect_to movies_path(ratings: session[:ratings], sort: session[:sort])
    end
  end
  
  
  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
