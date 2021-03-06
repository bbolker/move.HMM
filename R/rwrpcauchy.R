#'Wrapped cauchy random number generation
#'
#'This function generates random number from the wrapped cauchy distribution.
#'It is modified from the function in the CircStats package so that it can
#'evaluate multiple parameter combinations in the same call.
#'
#'@param n The number of random numbers to generate
#'@param mu A value for the mu parameter
#'@param rho A value for the concentration parameter in the interval [0,1]
#'@return A vector of random numbers drawn from a wrapped cauchy distribution
#'@export

rwrpcauchy=function(n, mu = 0, rho = exp(-1)) 
{
  if(length(mu)!=length(rho))stop("Dimension of mu and rho must be equal")
  ## OR, unconditionally, mu=rep(mu,length.out=n)
  if(length(mu)==1){
      mu=rep(mu,n)
  }
  if(length(rho)==1){
      rho=rep(rho,n)
  }
    
  result=rep(NA,n)
  case1=which(rho==0)
  case2=which(rho==1)
  case3=1:n
  if(length(cc <- c(case1,case2))>0){
    case3=case3[-cc]
  }
  if(length(case1)>0){
      result[case1]=runif(length(case1), 0, 2 * pi)
  }
  if(length(case2)>0){
    result[case2]= rep(mu, length(case2))
  }
  if(length(case3)>0){
    scale <- -log(rho[case3])
    result[case3] <- rcauchy(length(case3), mu, scale)%%(2 * pi)
  }
  #shift support to (-pi,pi)
  result[result>pi]=result[result>pi]-2*pi
  result  
}
