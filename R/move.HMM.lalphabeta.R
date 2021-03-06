#'Compute forward and backwards probabilities
#'
#'This function, modified from Zucchini and MacDonald (2009), computes the forward
#'and backwards probabilities defined by Equations (4.1) and (4.2) on page 60
#'in Zucchini and MacDonald (2009).  It takes as input a move.HMM object.  This function
#'is used to create pseudo-residuals and in local decoding.
#'
#'@param move.HMM a move.HMM object containing a fitted HMM model.
#'@include Distributions.R
#'@return A 2 element list containing the forward and backwards probabilities.
#'@export
move.HMM.lalphabeta <-function(move.HMM)
{
  #Alternatively, the forward probabilies could be stored when fitting the model, but recalculation
  #is not that time consuming.
  obs <- move.HMM$obs
  params <- move.HMM$params
  nstates <- move.HMM$nstates
  dists <- move.HMM$dists
  out <- Distributions(dists,nstates)
  PDFs <- out[[3]]
  n <- dim(obs)[1]
  allprobs <- matrix(rep(1,nstates*n),nrow=n)#f(y_t|s_t=k)
  lalpha=lbeta=pre <- matrix(rep(1,nstates*n),nrow=n)
  use=!is.na(obs)*1
  ndists=length(PDFs)
  if(nstates>1){
    nparam=unlist(lapply(params,ncol))[-1]
  }else{
    nparam=unlist(lapply(params,ncol))
  }
  for(i in 1:ndists){
    if(nparam[i]==2){
      #for 2 parameter distributions
      for (j in 1:nstates){
        allprobs[use[,i],j] <- allprobs[use[,i],j]*PDFs[[i]](obs[use[,i],i],params[[i+1]][j,1],params[[i+1]][j,2])
      }
    }else if(nparam[i]==1){
      #for 1 parameter distributions. 
      for (j in 1:nstates){
        allprobs[use[,i],j] <- allprobs[use[,i],j]*PDFs[[i]](obs[use[,i],i],params[[i+1]][j])
      }
    }else if(nparam[i]==3){
      #for 3 parameter distributions
      for (j in 1:nstates){
        allprobs[use[,i],j] <- allprobs[use[,i],j]*PDFs[[i]](obs[use[,i],i],params[[i+1]][j,1],params[[i+1]][j,2],params[[i+1]][j,3])
      }
    }
  }
  m <- nstates
  delta=move.HMM$delta
  foo <- delta*allprobs [1,]
  sumfoo <- sum(foo)
  lscale <- log(sumfoo)
  foo <- foo/sumfoo
  pre[1,] <- foo
  lalpha [1,] <- log(foo)+lscale
  for (i in 2:n)
  {
    foo <- foo %*% params[[1]] *allprobs[i,]
    sumfoo <- sum(foo)
    lscale <- lscale+log(sumfoo)
    foo <- foo/sumfoo
    pre[i,] <- foo
    lalpha[i,] <- log(foo) +lscale
  }
  lbeta[n,] <- rep(0,m)
  foo <- rep (1/m,m)
  lscale <- log(m)
  for (i in (n-1) :1){
    foo <- params[[1]]  %*%( allprobs[i+1,]*foo)
    lbeta[i,] <- log(foo) +lscale
    sumfoo <- sum(foo)
    foo <- foo/sumfoo
    lscale <- lscale+log(sumfoo)
  }
  list(la = lalpha ,lb = lbeta,pre = pre)
}