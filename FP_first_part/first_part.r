# The following code follows the kaggle tutorial 
# https://www.kaggle.com/c/facial-keypoints-detection/details/getting-started-with-r
# which generates a .csv submission file that scores 3.96244
# it ccomputes the mean of each column for the first image in the dataset
# then it estimates the mean of each column for the rest images
# If the mean is calculated for each single image following the same
# principle, the end results will be more accurate
# (we are aiming for at least: 3.80685) :)

data.dir   <- '~/Documents/QMUL/DM/Titanic_Savers/FP/FP_first_part/'
train.file <- paste0(data.dir, 'training.csv')
test.file  <- paste0(data.dir, 'test.csv')

d.train <- read.csv(train.file, stringsAsFactors=F)

str(d.train)

?read.csv #documentation for data input :) -> quite useful
q #exits reading the doc

head(d.train)

im.train      <- d.train$Image # R dataframe defined
d.train$Image <- NULL # Image column gets excluded

head(d.train)

im.train[1]

as.integer(unlist(strsplit(im.train[1], " ")))

install.packages('doMC')

library(doMC)
registerDoMC()

im.train <- foreach(im = im.train, .combine=rbind) %dopar% {
    as.integer(unlist(strsplit(im, " ")))
}

str(im.train)

d.test  <- read.csv(test.file, stringsAsFactors=F)

im.test <- foreach(im = d.test$Image, .combine=rbind) %dopar% {
    as.integer(unlist(strsplit(im, " ")))
}

d.test$Image <- NULL

save(d.train, im.train, d.test, im.test, file='data.Rd')

load('data.Rd')


im <- matrix(data=rev(im.train[1,]), nrow=96, ncol=96)
image(1:96, 1:96, im, col=gray((0:255)/255))
points(96-d.train$nose_tip_x[1],         96-d.train$nose_tip_y[1],         col="red")
points(96-d.train$left_eye_center_x[1],  96-d.train$left_eye_center_y[1],  col="blue")
points(96-d.train$right_eye_center_x[1], 96-d.train$right_eye_center_y[1], col="green")
for(i in 1:nrow(d.train)) {
    points(96-d.train$nose_tip_x[i], 96-d.train$nose_tip_y[i], col="red")
}
idx <- which.max(d.train$nose_tip_x)
im  <- matrix(data=rev(im.train[idx,]), nrow=96, ncol=96)
image(1:96, 1:96, im, col=gray((0:255)/255))
points(96-d.train$nose_tip_x[idx], 96-d.train$nose_tip_y[idx], col="red")
colMeans(d.train, na.rm=T)
p           <- matrix(data=colMeans(d.train, na.rm=T), nrow=nrow(d.test), ncol=ncol(d.train), byrow=T)
colnames(p) <- names(d.train)
predictions <- data.frame(ImageId = 1:nrow(d.test), p)
head(predictions)

library(reshape2)
submission <- melt(predictions, id.vars="ImageId", variable.name="FeatureName", value.name="Location")
head(submission)
example.submission <- read.csv(paste0('IdLookupTable.csv'))
sub.col.names      <- names(example.submission)
example.submission$Location <- NULL
submission <- merge(example.submission, submission, all.x=T, sort=F)
submission <- submission[, sub.col.names]
write.csv(submission, file="keypoints_prediction.csv", quote=F, row.names=F)













