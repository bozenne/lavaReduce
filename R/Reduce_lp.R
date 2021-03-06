# {{{ lp

# {{{ doc
#' @title Extract the linear predictors
#' @name lp
#' @description Extract the linear predictors of a lvm object
#' 
#' @param x \code{lvm}-object
#' @param type slot to be return. Can be \code{"link"}, \code{"x"}, \code{"con"}, \code{"name"}
#' @param lp which linear predictor to consider
#' @param format should the results be kept as the list or returned as a single vector
#' @param ... additional arguments to be passed to the low level functions
#' 
#' @examples 
#' ## regresssion
#' m <- lvm.reduced()
#' m <- regression(m, x=paste0("x",1:10),y="y", reduce = TRUE)
#' lp(m)
#' lp(m, type = c("x","link"), format = "list2")
#' lp(m, type = NULL)
#' 
#' ## lvm
#' m <- lvm.reduced()
#' m <- regression(m, x=paste0("x",1:10),y="y1", reduce = TRUE)
#' m <- regression(m, x=paste0("x",51:150),y="y2", reduce = TRUE)
#' covariance(m) <- y1~y2
#' 
#' lp(m)
#' lp(m, type = "x", format = "list")
#' lp(m, lp = 1, type = "link")
#' @rdname lp 
#' @export
`lp` <- function(x,...) UseMethod("lp")
# }}}

# {{{ lp.lvm.reduced
#' @rdname lp 
#' @export
lp.lvm.reduced <- function(x, type = "name", lp = NULL, format = "vector", ...){
 
  if(length(x$lp)==0){return(NULL)} 
  validNames <- c("link","con","name","x","endo") # names(x$lp[[1]])
  
  ## type
  if(is.null(type)){
    type <- c("con","name","x")
    size <- FALSE
    format <- "list2"
  }else if(length(type) == 1 && type == "endogeneous"){
    return(names(x$lp))
  }else if(length(type) == 1 && type == "n.link"){
    type <- "link"
    size <- TRUE
    format <- "list"
  }else{
    if(any(type %in% validNames == FALSE)){
      stop("type \"",paste(type[type %in% validNames == FALSE], collapse = "\" \""),"\" is not valid \n",
           "valid types: \"",paste(validNames, collapse = "\" \""),"\" \n")
    }
    size <- FALSE
  }
  
  ## add links
  if("link" %in% type){
    
    for(iterLP in names(x$lp)){
      if(length(x$lp[[iterLP]]$x)>0){
        x$lp[[iterLP]]$link <- paste(iterLP,x$lp[[iterLP]]$x,sep=lava.options()$symbol[1])
      }else{
        x$lp[[iterLP]]$link <- NULL
      }
    }
    
  }
  
  if("endo" %in% type){
    
    for(iterLP in names(x$lp)){
        x$lp[[iterLP]]$endo <- iterLP
    }
    
  }
  
  ## format
  validFormat <- c("vector","list","list2")
  if(format %in% validFormat == FALSE){
    stop("format ",format," is not valid \n",
         "format must be on of : \"",paste(validFormat, collapse = " ")," \n")
  }
  if(format != "list2" && length(type)>1){
    stop("format must be \"list2\" when length(type) is not one \n",
         "length(type): ",length(type)," \n")
  }
  
  ## select lp
  if(is.null(lp)){
    lp <- seq_len(length(x$lp))
  }else if(is.numeric(lp)){
    vec <- seq_len(length(x$lp))
    if(any(lp %in% vec == FALSE)){
      stop("lp ",paste(lp, collapse = " ")," is not valid \n",
           "if numeric lp must be in: \"",paste(vec, collapse = " ")," \n")
    }
  }else if(is.character(lp)){
    vec <- unlist(lapply(x$lp, function(x)x[["name"]]))
    if(any(lp %in% vec == FALSE)){
      stop("lp ",paste(lp, collapse = " ")," is not valid \n",
           "if character lp must be in: \"",paste(vec, collapse = "\" \""),"\" \n")
    }
    lp <- match(lp, vec)
  }else{
    stop("lp must be a numeric or character vector \n")
  }
  
  ## extract 
  if(format == "list"){
    res <- lapply(x$lp[lp], function(x)x[[type]])
    
    if(size){
      res <- unlist(lapply(res, function(x) length(x)))
      names(res) <- unlist(lapply(x$lp[lp], function(x)x[["name"]]))
    }
    
  }else{
    res <- lapply(x$lp[lp], function(x)x[type])
  }
  
  ## export
  if(format == "vector"){
    res <- unlist(res)
  }
  
  return(res)
  
}
# }}}

# }}}

# {{{ lp<-

# {{{ doc
#' @title Update linear predictors
#' @name updateLP
#' @description Update linear predictors of a lvm object
#' 
#' @param x \code{lvm}-object
#' @param lp the name of the linear predictors to be updated
#' @param value the value that will be allocated
#' @param ... additional arguments to be passed to the low level functions
#' 
#' @examples 
#' ## regresssion
#' m <- lvm.reduced()
#' m <- regression(m, x=paste0("x",1:10),y="y", reduce = TRUE)
#' 
#' newLP <- lp(m, type = NULL)[[1]]
#' newLP$link <- newLP$link[1:3]
#' newLP$con <- newLP$con[1:3]
#' newLP$x <- newLP$x[1:3]
#' 
#' lp(m, lp = 1) <- newLP
#' lp(m, type = NULL)
#' 
#' 

#' @rdname updateLP
#' @export
`lp<-` <- function(x, ..., value) UseMethod("lp<-")
# }}}

# {{{ lp<-.lvm.reduce
#' @rdname updateLP 
#' @export
`lp<-.lvm.reduced` <- function(x, lp = NULL, ..., value){
  
  if(is.null(lp)){
    
    x$lp <- value
    
  }else{
    
    ## valid LP
    if(is.numeric(lp)){
      vec <- seq_len(length(x$lp))
      if(any(lp %in% vec == FALSE)){
        stop("lp ",paste(lp, collapse = " ")," is not valid \n",
             "if numeric lp must be in: \"",paste(vec, collapse = " ")," \n")
      }
    }else if(is.character(lp)){
      vec <- unlist(lapply(x$lp, function(x)x[["name"]]))
      if(any(lp %in% vec == FALSE)){
        stop("lp ",paste(lp, collapse = " ")," is not valid \n",
             "if character lp must be in: \"",paste(vec, collapse = " ")," \n")
      }
      lp <- match(lp, vec)
    }
    
    if(length(lp) == 1 && length(value) == 3 && all(names(value) == c("con","name","x"))){
      value <- list(value)
    }

    x$lp[lp] <- value
    
  }
  
  return(x)
  
}
# }}}

# }}}
