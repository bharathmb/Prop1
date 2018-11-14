#' Print Summary
#' 
#' Wrapper for summary
#' 
#' @export
#' @param df_full some object or dataset
printsummary <- function(df_full, dvname, preddv){
  #override default 
  options(max.print=99999999);
  options(width=120);
  
  
  ############### Data Cleaning function ############
  
  data_prep_code_fun <- function(df_full, dv) {
  data<-df_full

#consider target variable name given as input in HybridFS function as DV'
n <- dv

if(length(unique(data[[n]]))!=2)
{
  stop("Error: Dependent variables should be 2 for binary classification!")
}
df_temp<-data
names(data)[names(data)==n] <- "DV"

#get the list of categorical variables
cat_var=data.frame()

df_temp<-df_temp[, names(df_temp) != n] 

#get the list of character variables
char <- df_temp[sapply(df_temp,is.character)]
cat_var<-char

#get the list of logical variables 
logcl <- df_temp[sapply(df_temp, is.logical)]
cat_var<-cbind(cat_var,logcl)

#removing the categorical variables in cat_var 
df_temp<-df_temp[, !sapply(df_temp,is.logical)]
df_temp<-df_temp[, !sapply(df_temp,is.character)]

#determining other categorical variables with less than 52 levels
unique_lvl_cnt<-df_temp[lengths(lapply(df_temp, unique))<=52]
cat_var<-cbind(cat_var,unique_lvl_cnt)

cat_var_names<-list()
cat_var_names<-names(cat_var)

#display the list of categorical variables
cat_var_names

######################################################################################################################################################
#Categorical variables treatment
######################################################################################################################################################
#Steps
#Replace missing values as "Unknown" in categorical variables 
#Check for categorical variables with more than 52 levels and reduce them to the top 10 levels that occur frequently 

#convert categorical variables to factors and unique variables treatment
for(j in cat_var_names)
{
  data[,j]<-as.factor(data[,j])
  if(length(unique(data[[j]])) == nrow(data))
  {
    data<-data[, names(data) != j] 
  }
}

#Identify replace the missing values as Unknown in categorical variables

df_cat <- data[,sapply(data,is.factor)]
df_cat <- df_cat[, names(df_cat) != "DV"]
if(ncol(df_cat)>0)
{
  for (i in 1:ncol(df_cat))
  {
    levels <- levels(df_cat[,i])
    
    if('Unknown' %in% levels)
    {}else{
      levels[length(levels) + 1] <- 'Unknown'
      df_cat[,i] <- factor(df_cat[,i], levels = levels)          
    }
    
    # refactor to include "Unknown" as a factor level
    # and replace NA, null, blanks and ? with "Unknown"
    df_cat[,i] <- factor(df_cat[,i], levels = levels)
    df_cat[,i][is.na(df_cat[,i])] <- "Unknown"
    df_cat[,i][is.null(df_cat[,i])] <- "Unknown"
    df_cat[,i] <- sub("[?]", "Unknown", df_cat[,i])
    df_cat[,i] <- sub("^$", "Unknown", df_cat[,i])
    df_cat[,i]<-as.factor(df_cat[,i])
  }
  
  #Check for categorical variables with more than 52 levels and reduce them to the top 10 levels that
  #occur frequently 
  for(i in names(df_cat))
  {
    column<-df_cat[,i]
    uniq_lvls_cnt <- length(unique(column))
    temp<-as.data.frame(column)
    if (uniq_lvls_cnt>52)
    { temp<-data.frame()
    cat_freq_cnt <- data.frame(table(column))
    cat_freq_cnt <- cat_freq_cnt[ which(cat_freq_cnt$column!='Unknown' ),]
    cat_sort <- cat_freq_cnt[order(-cat_freq_cnt$Freq),]
    top_1<-head(cat_sort,10)
    top<-as.character(top_1[,1])
    
    data_cnt<-length(column)
    
    
    levels = unique(column)
    levels=as.character(levels)
    temp <- factor(temp, levels = levels)          
    
    if('Unknown' %in% levels)
    {}else{
      levels[length(levels) + 1] <- 'Unknown'
      temp <- factor(temp, levels = levels)          
    }
    
    for(k in 1:data_cnt)
    {
      value<-column[k]
      if(value %in% top)
      {
        temp<-rbind(temp,as.character(value))
      }else
      { 
        temp<-rbind(temp,'Unknown')
      }
    }}
    df_cat[,i]<-temp
  }
  
  
  #**********dv leakage code begin*************
  df_factor_check<-data.frame()
  dvleak_data<-df_cat
  dvleak_data$DV <- ifelse(data$DV==unique(data$DV)[1], 0, 1)
  for (fac in colnames(dvleak_data))
  {
    len<-1
    if (class(dvleak_data[,fac])=="factor")
    {
      df_factor<-dvleak_data[,c("DV",fac)]
      num_dv<-aggregate(DV~.,df_factor,sum)
      num_levels <- aggregate(DV~.,df_factor,length)
      df_factor_final<-merge(num_levels,num_dv,by=fac)
      
      while(len<=nrow(num_dv))
      {
        output_matrix <- as.data.frame(matrix(data=c(
          fac,
          as.character(df_factor_final[len,1]),
          df_factor_final[len,2],
          df_factor_final[len,3]
        ),nrow=1,ncol=4))
        df_factor_check <- rbind(df_factor_check, output_matrix)
        len = len + 1
      }
    }
  }
  
  sum_dv<-sum(df_factor$DV==1)
  df_factor_check<-cbind(df_factor_check,sum_dv)
  colnames(df_factor_check)[1]<-"Variable"
  colnames(df_factor_check)[2]<-"Factor_levels"
  colnames(df_factor_check)[3]<-"Records_each_level"
  colnames(df_factor_check)[4]<-"Num_Records_DV=1"
  colnames(df_factor_check)[5]<-"Sum_of_DV"
  
  df_factor_check$`Num_Records_DV=1`<-as.numeric(as.character(df_factor_check$`Num_Records_DV=1`))
  
  for ( i in 1:nrow(df_factor_check))
  {
    df_factor_check$dv_leak[i]<-(df_factor_check$Sum_of_DV[i])-(df_factor_check$`Num_Records_DV=1`[i])
  }
  
  # subset for dv_leak =0 and delete the variables in the original data set.
  #df_factor_check$`Num_Employees_DV=1`<-as.numeric(as.character(df_factor_check$`Num_Employees_DV=1`))
  
  rem_names=as.character(df_factor_check[df_factor_check$dv_leak==0,]$Variable) #Response same for 90% of the employees
  if(length(rem_names)!=0)
  {
    for ( i in 1:length(rem_names))
    {
      df_cat[,rem_names[i]]<-NULL
    }
  }
}
#******DV leakage code ends**************


######################################################################################################################################################
#continuous variables treatment
######################################################################################################################################################

#Steps
#first get the correlation matrix
#get the variable pairs that highly correlated
#bin the variables using woe binning
#get the significance of these binned variables using chi square test. 
#Remove variables from highly correlated variable list that are not significant
#check if muliticollinearity still exists and keep removing variables until vif drops below 5 for all variables
#get the binned version of the continuous variables 

df<-data

#Removing categorical variables from data
for(i in names(cat_var))
{
  df<-df[, names(df) != i] 
}
#unique variables treatment if ID is not categorical
for(i in names(df))
{
  if(grepl("id", i) | grepl("ID", i))
  {
    if(length(unique(df[[i]])) == nrow(df))
    {
      df<-df[names(df) != i]
    }
  }
}

df1<-df%>%data.frame()

#creating correlation matrix for continuous variables
if(length(df1)>1)
{
  df1<-df1[complete.cases(df1),]
  ##New Change - Sai - DV should not be sent for correlation check
  corr<-round(cor(df1[,names(df1) != 'DV']),2)
  corr_val<-corr
  
  corr_val[lower.tri(corr_val,diag=TRUE)]=NA # make all the diagonal elements as NA
  corr_val<-as.data.frame(as.table(corr_val)) # as a dataframe
  corr_val<-na.omit(corr_val) # remove NA
  corr_val<-corr_val[with(corr_val, order(-Freq)), ] # order by correlation
  corr_test_var<-subset(corr_val,Freq>=0.85)
  
  
  #adding ".binned" to each variable
  ##New Change - Sai - Check if the df is not empty before operation
  if(nrow(corr_test_var) > 0)
  {
    corr_test_var$Var1<-paste(corr_test_var$Var1,"binned",sep = ".")
    corr_test_var$Var2<-paste(corr_test_var$Var2,"binned",sep = ".")
    
  }
  
  #woe binning
  var_del<-as.character(names(df))
  
  binning <- woeBinning::woe.binning(df, 'DV', df)
  tabulate.binning <- woeBinning::woe.binning.table(binning)
  
  data_cont_binned <- woeBinning::woe.binning.deploy(data, binning)
  names(data_cont_binned)
  
  #removing original values of variables that have been binned
  for(i in var_del)
  {
    data_cont_binned<-data_cont_binned[, names(data_cont_binned) != i] 
  }
  
  data_cont_binned[is.na(data_cont_binned)] <- "Missing"
  
  data_cont_binned$DV<-data$DV
  
  #getting the correlated variables as a unique list
  ##New Change - Sai - Check if there are any correlated variables before
  ##applying treatments
  if(nrow(corr_test_var) > 0)
  {
    corr_var<-list()
    corr_var<-corr_test_var$Var1
    corr_var<-c(corr_var,corr_test_var$Var2)
    corr_var_unique<-unique(corr_var)
    
    
    #getting the chi sq for each highly correlated variable
    corr_var_chsq <- data.frame()
    
    for(each in corr_var_unique)
    {
      
      p_val=chisq.test((data_cont_binned[[each]]),data_cont_binned$DV)$p.value
      c <- data.frame('Var_name' = each,'p_value' = p_val)
      corr_var_chsq <- rbind(corr_var_chsq,c)
    }
    
    #remove the highly correlated variables that are not significant
    corr_var_insig<-as.character(corr_var_chsq[which(corr_var_chsq$p_value>0.05),1])
    
    #stripping off the "'binned" from variable names
    corr_var_insig_strip<-substr(corr_var_insig, 1, nchar(corr_var_insig)-7) 
    
    #removing the insignificant variables 
    for (f in corr_var_insig) {
      df1[[f]] <- NULL
    }
  }
  df1$DV <- ifelse(df1$DV==unique(df1$DV)[1], 0, 1)
  #checking if we still have multi collinearity and removing variables with very high vif until no such variable exists
  # Fit a model to the data
  fit=glm(DV ~ ., data=df1,family=binomial)
  ##New Change - Nithya - Check if there are linearly dependent variables in the model and remove it
  df_alias <- attributes(alias(fit)$Complete)$dimnames[[1]]
  if(!is.null(df_alias))
  {
    for(i in df_alias)
    {
      df1<-df1[, names(df1) != i]
    }
    # Fit a model to the data
    fit=glm(DV ~ ., data=df1,family=binomial)
  }
  # Calculating VIF for each independent variable
  vif(fit)
  
  # Set a VIF threshold. All the variables having higher VIF than threshold
  #are dropped from the model
  threshold=5
  
  # Sequentially drop the variable with the largest VIF until
  # all variables have VIF less than threshold
  drop=TRUE
  
  aftervif=data.frame()
  while(drop==TRUE) {
    vfit=vif(fit)
    aftervif=rbind.fill(aftervif,as.data.frame(t(vfit)))
    if(max(vfit)>threshold) { fit=
      update(fit,as.formula(paste(".","~",".","-",names(which.max(vfit))))) }
    else { drop=FALSE }}
  
  # How variables were removed sequentially
  t_aftervif= as.data.frame(t(aftervif))
  
  # Final (uncorrelated) variables and their VIFs
  vfit_d= as.data.frame(vfit)
  
  rem_var<-as.character(rownames(vfit_d))
  
  #retaining only the uncorrelated variables in the final data
  df<-df[ , rem_var]
  
  #getting the concatenated version of variables that needs to be retained
  rem_var<-paste(rem_var,"binned",sep=".")
  
  #getting the binned continuous variables 
  data_cont_binned_fin<-data_cont_binned[,rem_var]
}
######################################################################################################################################################
#getting the final data frame with the required variables
######################################################################################################################################################

#Creating dummy variables
if(length(df_cat)>0)
{
  df_cat_dummy <- dummyVars(~ ., data = df_cat, fullRank = TRUE, sep = "_")
  df_cat <- predict(df_cat_dummy, df_cat)
}
if(length(df1)>1)
{
  data_cont_binned_fin_dummy <- dummyVars(~ ., data = data_cont_binned_fin, fullRank = TRUE, sep = "_")
  data_cont_binned_fin <- predict(data_cont_binned_fin_dummy, data_cont_binned_fin)
  data_cont_binned_fin <- data_cont_binned_fin[,!grepl("Missing$",colnames(data_cont_binned_fin))]
  df_cat <- cbind(df_cat, data_cont_binned_fin)
}
##New Change - Sai - DV should be added since the df_cat
## is used in building final dataframe
final_data_after_processing=data.frame()

final_data_after_processing<-df_cat
final_data_after_processing<-cbind(final_data_after_processing,select(data,.data$DV))
return(final_data_after_processing)
}


  
   ##Calling the Data Cleaning function HERE!!
   df_cleaned<-data_prep_code_fun(df_full);
   write.csv(df_cleaned,"C:/opencpuapp_ip/cleaned_data.csv");  
  print(summary(df_cleaned))
  invisible()
}
