#' Make a random plot
#' 
#' This function creates a random histogram plot.
#' 
#' @export
#' @param n numer of random values 
#' @param dist one of "normal" or "uniform".
randomplot <- function(nfield,distfield,title){
  #input validation
    hist(rnorm(1000),main=title)
  invisible();  
}
