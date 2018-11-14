variable_profiling_function  <- function(dv, var) {
  
  library(ggplot2)
  
  dat = read.csv("c:/opencpuapp_ip/data_after_binning.csv")
  
  drops <- c("X")
  dat<-dat[ , !(names(dat) %in% drops)]
  
  var1 = dat[,var]
  dv = dat[,dv]
  
  freq <- table(var1,dv)
  total <- freq[,"0"]+freq[,"1"]
  meaniv = freq[,"1"]/total
   ggplot(dat, aes(var1, fill=dv)) + geom_bar(stat="count",position=position_dodge()) +
   #p <- ggplot(diab_train, aes(npreg, fill=diabeties)) + geom_bar(stat="count",position=position_dodge()) + 
   # scale_fill_manual(values=c("#999999", "#E69F00")) + 
   labs(title = "Bivariate Analysis") + 
   geom_hline(aes(yintercept = mean(meaniv)*100)) +
   theme(
     panel.background = element_rect(fill = "aliceblue",
                                     colour = "lightblue",
                                     size = 0.5),
     panel.grid.major = element_line(size = 0.5, linetype = 'solid',
                                     colour = "white"), 
     panel.grid.minor = element_line(size = 0.25, linetype = 'solid',
                                     colour = "lightblue")
   )
  
}
