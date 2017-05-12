## Custom functions for data transformation ##
first.last.impute <- function(matrix, na.col){
  
  # extract variable of interest and bind to ID vector
  data <-     as.data.frame(cbind(
    matrix[,na.col], # Vector containing missing
    1:length(matrix[,na.col]) # Vector of numbers from 1 to no of values in missing variable
  ))
  missing <-   is.na(data$V1) # Check for missing
  no.of.missing <- length(which(missing==T)) # Note number of missing
  
  if(no.of.missing<length(data$V1)){ # If entire set is missing, do nothing  
    
    if(missing[1]==T){ #If first value is missing, apply first known value to all missing before it
      
      duplicate <- duplicated(missing)
      
      first.data <- which(duplicate==F & missing==F) # Find first non-NA
      
      data$V1[which(data$V2<first.data)] <- data$V1[first.data] # Replace any missing before first non-na with first non-na
      
      matrix[,na.col] <- data$V1
      
    }
    
    # Repeat for values at end of set by reversing the vector and applying same method
    rev.missing   <- rev(missing)
    if(rev.missing[1]==T){
      
      rev.duplicate <- duplicated(rev.missing)
      
      rev.first.data <- which(rev.duplicate==F & rev.missing==F)
      rev.data <- as.data.frame(cbind(
        rev(data$V1),
        1:length(data$V1)
      ))
      rev.data$V1[which(rev.data$V2<rev.first.data)]<- rev.data$V1[rev.first.data]
      
      matrix[,na.col] <- rev(rev.data$V1) 
    }
    
  }
  
  return(matrix)
}
repeat.previous.impute <- function(matrix, na.col){
  # Input: Matrix of data and the column number of variable of interest
  # Looks for missing in the column of interest and replaces them with previous value
  # Should be run after first.last.impute to make sure there is a previous value to copy.
  
  data <-     as.data.frame(cbind(
    matrix[,na.col],
    1:length(matrix[,na.col])
  ))
  
  missing <-   is.na(data$V1)
  no.of.missing <- length(which(missing==T))
  
  # if missing present, run loop. if not, do nothing
  if(no.of.missing>0){
    if(no.of.missing<length(data$V1)){
      # run loop that finds each missing and replaces with previous value
      for (iter in(1:no.of.missing)){
        # Find first NA
        missing <-   is.na(data$V1)
        duplicate <- duplicated(missing)
        first.na <- which(duplicate==F & missing==T)
        
        # Replace any missing before first non-na with first non-na
        data$V1[which(data$V2==first.na)] <- data$V1[(first.na-1)]
      }
    }# If no.of.missing is lower than amount of units in set
  }# If no.of.missing is greater than 0
  matrix[,na.col] <- data$V1
  return(matrix)
}
flp.impute <- function(matrix,id.col,na.col){
  # Input: Matrix of data, the column number of an ID variable, and colnumber of the variable of interest
  # Imputes missing by replacing missing at start with first data,
  # replacing missing at the end with last data, and replacing
  # missing mid-set with previous valid value.
  require(dplyr)
  require(plyr)
  imp_mat_list <- by(matrix, as.factor(matrix[,id.col]), function(x) first.last.impute(x,na.col))
  
  imp_data_merged <- ldply(imp_mat_list, data.frame)
  matrix <- imp_data_merged[,2:ncol(imp_data_merged)]
  
  imp_mat_list <- by(matrix, as.factor(matrix[,id.col]), function(x) repeat.previous.impute(x,na.col))
  
  
  imp_data_merged <- ldply(imp_mat_list, data.frame)
  matrix <- imp_data_merged[,2:ncol(imp_data_merged)]
  
  return(matrix)
}
years.since.vector <- function(input){
  # Input: Binary vector.
  # Creates a vector that counts the time units since the last
  # occurence of a positive value in the input vector.
  #
  
  a <- vector(mode = "numeric", length = length(input))
  
  for (i in (1:length(input))){
    j <- i-1  
    if(i==1){ # If first iteration: Start at zero
      a[i] <- 0
    }
    
    if(i>1){ # If not first: Check for ongoing conflict.
      
      if(input[i]==0){ # If no conflict, add one year to previous value
        a[i] <- a[j]+1
      }else if (input[i]>=1){ # If conflict, reset to 0
        a[i] <- 0
      }
      
    }
    
  }
  
  return(a)
}
years.since <- function(matrix,id.col,lag.col){
  # Input: A matrix containing a vector you would like lagged.
  # This function will create a new variable that contains the
  # number of rows that has passed since an input vector had a
  # positive value.
  # !!! REQUIRES "years.since.vector"-function !!!
  require(dplyr)
  require(plyr)
  
  lag_vector_list <- by(matrix, as.factor(matrix[,id.col]), function(x) years.since.vector(x[,lag.col]))
  data_merged <- unlist(lag_vector_list)
  matrix <- cbind(matrix,data_merged)
  colnames(matrix)[ncol(matrix)] <- paste("ys.",colnames(matrix[lag.col]),sep="")
  
  return(matrix)
}
scale010=function(x,direction=c(0,1)){
  # Rescales a vector of numbers to span between 0 and 10.
  # First argument is the vector to be rescaled
  # Second argument indicates whether the vector should be inverted.
  if(sum(direction!=c(0,1))>=2){cat("Invalid direction! Please choose between 0 or 1.
                                    0 = Rescale from 0-10 with lowest score as 0 and highest as 10.
                                    1 = Rescale from 0-10 with lowest score as 10 and highest as 0.")}
  
  if(direction==0){rescaled=   10*(x-min(x,na.rm=T)) / (max(x,na.rm=T)-min(x,na.rm=T))
  return(rescaled) }
  
  if(direction==1){rescaled=10-10*(x-min(x,na.rm=T)) / (max(x,na.rm=T)-min(x,na.rm=T))
  return(rescaled) }
  
}

# Written by Martin Smidt (Trainee, GCRI) for the GCRI.
# "scale010" is a translation and adaption of code 
# provided kindly by Felipe Ortiz of INFORM Colombia.