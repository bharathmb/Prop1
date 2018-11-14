scoring_module<-function(oos_path,DV,model_selection){

  library(pROC)
  library(caret)
  
  train<-read.csv("C:/opencpuapp_ip/train_comp.csv")
  test<-read.csv(oos_path)
  
  drops <- c("X")
	train<-train[ , !(names(train) %in% drops)]
  test<-test[ , !(names(test) %in% drops)]

  k_stat_value<- function(fullmodel,train,test,flag){
    n=10
    model_iteration_train <- fullmodel
    
    #model_iteration_train <- step(fullmodel,k=3.8415)
    
    #Predictions
    #pred_train_iteration = predict(model_iteration_train, newdata = train, type =  'response')
    if(flag=="n"){
      pred_train_iteration = as.numeric(predict(model_iteration_train, newdata = train,type = 'response'))
    }
    if(flag=="y"){
      pred_train_iteration = as.numeric(predict(model_iteration_train, newdata = train))
    }
    train_KStat = train #90 rows
    train_KStat$pred = pred_train_iteration
    pred_train_iteration
    summary(train)
    KStat_train = subset(train_KStat, select = c('DV', 'pred'))
    KStat_train = KStat_train[order(-KStat_train$pred), ]
    KStat_train$row = seq(1, nrow(KStat_train), 1)
    
    
    
    
    # ******************** AUC ********************
    ROCR1_Iteration2 = ROCR::prediction(pred_train_iteration, train$DV)# to transform the input data into a standardized format
    auctrain_Iteration2 = as.numeric(ROCR::performance( ROCR1_Iteration2, "auc")@y.values)#predictor evaluations
    
    temp=0
    repeat{
      a_iteration = as.numeric(floor(nrow(train_KStat) / n), 0)
      
      #Gains Table
      KStat_train$flag<-sample(0, replace=TRUE, size=nrow(train_KStat))
      
      y=a_iteration
      j=0
      for(i in 1:n){
        KStat_train$flag[(j+1):y]<-i
        j=y
        if(i==n & y<nrow(train_KStat))
        {
          KStat_train$flag[(y+1):nrow(train_KStat)]<-i
        }
        y=y+a_iteration
        
      }
      
      Responders = 0
      
      for (i in 1:n)
      {
        Responders[i] = sum(KStat_train$DV[KStat_train$flag == i])
      }
      
      kstat = data.frame(Responders)
      
      ##Variables
      for (i in 1:n)
      {
        kstat$Non_Responders[i] = (sum(KStat_train$flag == i) - kstat$Responders[i])
      }
      
      kstat$Responders_Percentage = ((kstat$Responders) / sum(kstat$Responders)) *
        100
      
      kstat$Non_Responders_Percentage = ((kstat$Non_Responders) / sum(kstat$Non_Responders)) *
        100
      
      #*****Add the Risk indicator to the employee
      ##R-Cumm
      kstat$R_Cumm[n] = kstat$Responders_Percentage[nrow(kstat)]
      
      num = seq(n-1,1,-1)
      
      for (i in num)
      {
        kstat$R_Cumm[i] = kstat$R_Cumm[i + 1] + kstat$Responders_Percentage[i]
      }
      
      ##NR-Cumm
      
      kstat$NR_Cumm[n] = kstat$Non_Responders_Percentage[nrow(kstat)]
      
      num = seq(n-1,1,-1)
      
      for (i in num)
      {
        kstat$NR_Cumm[i] = kstat$NR_Cumm[i + 1] + kstat$Non_Responders_Percentage[i]
      }
      
      kstat$KS = round((kstat$NR_Cumm - kstat$R_Cumm), 2)
      
      num1 = seq(1,n,1)
      
      
      kstat$Model_Lift[n] = 100
      
      for (i in num)
      {
        kstat$Model_Lift[i] = 100 - kstat$R_Cumm[i + 1]
      }
      
      ##Decile determination
      
      for (i in num1)
      {
        if (kstat$KS[i + 1] > kstat$KS[i])
        {
          count = i + 1
        }
        else
        {
          break
        }
      }
      
      library(SDMTools)
      optimum_threshold = optim.thresh(KStat_train$DV, KStat_train$pred)
      thresh = optimum_threshold$`max.sensitivity+specificity`
      print(n)
      print(thresh)
      if(temp==max(thresh))
      {break}
      temp=max(thresh)
      n=n+10
    }  
    return(thresh)
  }
  
  
  evaluatemeasures <- function(DV,predicted_val,pred_roc){
    
    pred_f <- pred_roc
    library(EvaluationMeasures)
    #EvalMetrics <- data.frame(metrics=c("tpr","fpr","tnr","fnr","recall","precision","f1score"),value=c(0,0,0,0,0,0,0))
    tpr<-EvaluationMeasures.TPR(Real = DV,Predicted = predicted_val, Positive = 1)
    fpr<-EvaluationMeasures.FPR(Real = DV,Predicted = predicted_val, Positive = 1)
    tnr<-EvaluationMeasures.TNR(Real = DV,Predicted = predicted_val, Positive = 1)
    fnr<-EvaluationMeasures.FNR(Real = DV,Predicted = predicted_val, Positive = 1)
    recall<-EvaluationMeasures.Recall(Real = DV,Predicted = predicted_val, Positive = 1)
    precision<-EvaluationMeasures.Precision(Real = DV,Predicted = predicted_val, Positive = 1)
    f1score<-EvaluationMeasures.F1Score(Real = DV,Predicted = predicted_val, Positive = 1)
    Accuracy<-EvaluationMeasures.Accuracy(Real = DV,Predicted = predicted_val, Positive = 1)
    res = roc(as.numeric(DV), pred_f)
    plot_res <- plot(res)
    return(c(tpr,fpr,tnr,fnr,recall,precision,f1score,Accuracy,plot_res))
  }
  
  
  variable_importance <- function(var_imp_mod,flag_svm){
    library(party)
    if(flag_svm == "y"){
      mod_type <- var_imp_mod
      mod_imp <- varImp(mod_type,numTrees = 3000)
      mod_temp <- mod_imp$importance
      names <- c(rownames(mod_temp))
      mod_temp$var_names <- names
      rownames(mod_temp) <- NULL
      mod_temp <- mod_temp[,c("var_names","Overall")]
      mod_temp <- mod_temp[order(mod_temp$Overall,decreasing = TRUE),]
      rownames(mod_temp) <- NULL
      return(mod_temp)
    }
    else if(flag_svm == "not_app"){
      return()
    }
    else {
      mod_type <- var_imp_mod
      mod_imp <- varImp(mod_type,numTrees = 3000)
      names <- c(rownames(mod_imp))
      mod_imp$var_names <- names
      rownames(mod_imp) <- NULL
      mod_imp <- mod_imp[,c("var_names","Overall")]
      mod_imp <- mod_imp[order(mod_imp$Overall,decreasing = TRUE),]
      rownames(mod_imp) <- NULL
      return(mod_imp)
    }
  }
  
  
  
  names(train)[names(train)==DV] <- "DV"
  names(test)[names(test)==DV] <- "DV"

  ## checking for correlation
  #cor(train_gbm)
  
  if (model_selection == "select-4")
  {
    train_gbm<-train
    test_gbm<-test
    print("running GBM")
    #install.packages("gbm")
    library(gbm)
    gbm_model = gbm(DV~.+0, data=train_gbm, 
                    shrinkage=0.01, distribution = 'bernoulli', cv.folds=5, n.trees=3000, verbose=F)
    #identifying threshold
    threshold<-k_stat_value(gbm_model,train_gbm,test_gbm,"n")
    
    #head(train_gbm)
    #summary(gbm_model)
    best.iter = gbm.perf(gbm_model, method="cv")
    ##best.iter
    ##plot.gbm(gbm.model, 1, best.iter)
    
    ## predicting on the test dataset
    
    pred <- predict(gbm_model, newdata = test_gbm,type = 'response')
    
    ##install.packages("pROC")
  
    #auc(res)
    
    ##library(e1071)
    ##install.packages("caret")
    ##library(caret)
    ##fitControl = trainControl(method="cv", number=5, returnResamp = "none")
    
    ##train_gbm$DV = as.factor(train_gbm$DV)
    ##model2 = train(DV~.+0, data=train_gbm, method="gbm",
    ##               distribution="bernoulli", trControl=fitControl, verbose=F, 
    ##               tuneGrid=data.frame(.n.trees=best.iter, .shrinkage=0.01, .interaction.depth=1, 
    ##                                   .n.minobsinnode=1))
    
    ## prediction
    ##pred1 = predict(model2, newdata = test_gbm)
    
    ##test_gbm$DV = as.factor(test_gbm$DV)
    
    ## performance evaluation
    ##test_gbm$pred2 = as.numeric(pred)
    
    
    
    #res1 = roc(test_gbm$DV, test_gbm$pred2)
    #plot(res1)
    #auc(res1)
    test_gbm$pred2[pred>max(threshold)] <- as.numeric(1)
    test_gbm$pred2[pred<=max(threshold)] <- as.numeric(0)
    ##confusionMatrix(model2)
    
    ##confusionMratrix(pred1,test_gbm$DV)
    
    #calculating logloss
    #mResults = predict(model2, test_gbm, na.action = na.pass, type = "prob")
    #mResults$obs = test_gbm$diabetes
    #head(mResults)
    
    #mnLogLoss(mResults, lev = levels(mResults$obs))
    #test_gbm$DV<- as.numeric(test_gbm$DV) -1
    names(test_gbm)[names(test_gbm)=="pred2"] <- "DV"
    scored_dataset<-test_gbm
  }
  if (model_selection == "select-1")
  {
    print("running LR")
    train_lr<-train
    test_lr<-test
    lr_model <- glm (DV ~ ., data =train_lr, family = binomial)
    #summary(model)
    threshold<-k_stat_value(lr_model,train_lr,test_lr,"n")
    pred <- predict(lr_model, newdata=test_lr,
                    type = 'response')
    test_lr$predictedtype[pred>max(threshold)] <- as.numeric(1)
    test_lr$predictedtype[pred<=max(threshold)] <- as.numeric(0)
    
    names(test_lr)[names(test_lr)=="predictedtype"] <- "DV"
    scored_dataset<-test_lr
  }
  if (model_selection == "select-5")
  {
    print("running NB")
    train_nb<-train
    test_nb<-test
    ##install.packages("naivebayes")
    library(e1071)
    Naive_Bayes_Model = naiveBayes(as.factor(train_nb$DV) ~., data=train_nb)
    #What does the model say? Print the model summary
    summary(Naive_Bayes_Model)
    #Identifying threshold
    
    #Prediction on the dataset
    test_nb$NB_Predictions=predict(Naive_Bayes_Model,newdata=test_nb)
    test_nb$NB_Predictions<-as.numeric(test_nb$NB_Predictions)-1
 
    #Confusion matrix to check accuracy
    #table(NB_Predictions,test_nb$DV)
    pred <- as.numeric(test_nb$NB_Predictions)
    
    names(test_nb)[names(test_nb)=="NB_Predictions"] <- "DV"
    scored_dataset<-test_nb
  }
  
  if (model_selection == "select-2")  {
    print("running RF")
    train_rf <-train
    test_rf <- test
    library(randomForest)
    library(ROSE)
    
    
    treeimp <- randomForest(DV ~ ., data = train_rf, ntrees=100,importance=T)
    #Identifying threshold
    threshold<-k_stat_value(treeimp,train_rf,test_rf,"n")
    test_rf$treeimb <- predict(treeimp, newdata = test_rf)
    test_rf$predictedtype[test_rf$treeimb>max(threshold)] <- as.numeric(1)
    test_rf$predictedtype[test_rf$treeimb<=max(threshold)] <- as.numeric(0)
    names(test_rf)[names(test_rf)=="predictedtype"] <- "DV"
    scored_dataset<-test_rf
    #over sampling
    # data_balanced_over <- ovun.sample(DV ~ ., data = train_rf, method = "over",)$data
    # 
    # table(data_balanced_over$DV)
    # #undersampling
    # data_balanced_under <- ovun.sample(DV ~ ., data = train_rf, method = "under", seed = 1)$data
    # table(data_balanced_under$DV)
    # 
    # #both
    # data_balanced_both <- ovun.sample(DV ~ ., data = train_rf, method = "both", p=0.5, seed = 1)$data                            
    # table(data_balanced_both$DV)
    # 
    # #rose
    # data.rose <- ROSE(DV ~ ., data = train_rf, seed = 1)$data
    # table(data.rose$cls)
    # library(rpart)
    # #build decision tree models
    # tree.rose <- rpart(DV ~ ., data = data.rose)
    # tree.over <- rpart(DV ~ ., data = data_balanced_over)
    # tree.under <- rpart(DV ~ ., data = data_balanced_under)
    # tree.both <- rpart(DV ~ ., data = data_balanced_both)
    # 
    # #make predictions on unseen data
    # pred.tree.rose <- predict(tree.rose, newdata = test_rf)
    # pred.tree.over <- predict(tree.over, newdata = test_rf)
    # pred.tree.under <- predict(tree.under, newdata = test_rf)
    # pred.tree.both <- predict(tree.both, newdata = test_rf)
    # 
    # test_rf$predicted_tree_both[pred.tree.both>max(threshold)] <- as.numeric(1)
    # test_rf$predicted_tree_both[pred.tree.both<=max(threshold)] <- as.numeric(0)
    # 
    # model_evaluations["rf_both",] <- evaluatemeasures(test_rf$DV,test_rf$predicted_tree_both,pred.tree.both)
    # rf_both_imp <- variable_importance(tree.both,"n")
    # 
    # test_rf$predicted_tree_over[pred.tree.over>max(threshold)] <- as.numeric(1)
    # test_rf$predicted_tree_over[pred.tree.over<=max(threshold)] <- as.numeric(0)
    # 
    # model_evaluations["rf_over",] <- evaluatemeasures(test_rf$DV,test_rf$predicted_tree_over,pred.tree.over)
    # rf_over_imp <- variable_importance(tree.over,"n")
    # 
    # test_rf$predicted_tree_under[pred.tree.under>max(threshold)] <- as.numeric(1)
    # test_rf$predicted_tree_under[pred.tree.under<=max(threshold)] <- as.numeric(0)
    # 
    # model_evaluations["rf_under",] <- evaluatemeasures(test_rf$DV,test_rf$predicted_tree_under,pred.tree.under)
    # rf_under_imp  <- variable_importance(tree.under,"n")
    # 
    # test_rf$predicted_tree_rose[pred.tree.rose>max(threshold)] <- as.numeric(1)
    # test_rf$predicted_tree_rose[pred.tree.rose<=max(threshold)] <- as.numeric(0)
    # 
    # model_evaluations["rf_rose",] <- evaluatemeasures(test_rf$DV,test_rf$predicted_tree_rose,pred.tree.rose)
    # rf_rose_imp <- variable_importance(tree.rose,"n")
  }
  if (model_selection == "select-3")
  {
    print("running SVM")
    train_svm<- train
    test_svm<- test
    #library(caret)
    trctrl <- trainControl(method = "repeatedcv", number = 10, repeats = 3)
    
    set.seed(323)
    
    svm_radial <- train(DV ~., data = train_svm, method = "svmRadial",
                        trControl=trctrl,
                        preProcess = c("center", "scale"),
                        tuneLength = 10)
    #Identifying threshold
    threshold<-k_stat_value(svm_radial,train_svm,test_svm,"y")
    
    test_pred <- as.numeric(predict(svm_radial,newdata = test_svm))
    test_pred <- predict(svm_radial,newdata = test_svm)
    
    #confusionMatrix(test_svm$predictedtype,test_svm$DV)
    
    test_svm$predictedtype[test_pred>max(threshold)] <- as.numeric(1)
    test_svm$predictedtype[test_pred<=max(threshold)] <- as.numeric(0)
    
    names(test_svm)[names(test_svm)=="predictedtype"] <- "DV"
    scored_dataset<-test_svm
  }
  scored_dataset<-scored_dataset[,-c(1,2)]
  names(scored_dataset)[names(scored_dataset)=="DV"] <- DV
  write.csv(scored_dataset,"c:/opencpuapp_ip/scored_dataset.csv")
 
}
