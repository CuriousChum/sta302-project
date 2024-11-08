################################################################################
# University of Toronto 2024
# STA302 Assignment
# Louis Tan, Maverick Luke, Tom Kim
################################################################################
# TASK 0: Setup
# - Load appropriate libraries
# - Load the dataset

# Load libraries
library(ggplot2)
library(dplyr)
library(mgcv)

# Object savant_data comes from HowToSavantData.R


################################################################################
# TASK 1: Clean the data
# - Right-handed pitcher, Fourseam fastball
# - Since we're calculating for whiff rate, filter it for all swings
# - (whiff rate is probability of swing & miss IF swing)
# - Remove incomplete data points (NA's)


# Filter to the appropriate sample we're looking for
RHP_FB <- savant_data |>
  filter(p_throws == "R", pitch_type == "FF",
         description %in% c("hit_into_play", "swinging_strike", "foul", "foul_tip")) |>
  mutate(whiff = if_else(description == "swinging_strike", 1, 0)
  )

# Remove all incomplete data points
RHP_FB0 <- RHP_FB |>
  filter(
    !is.na(stand),
    !is.na(strikes),
    !is.na(release_speed),
    !is.na(release_extension),
    !is.na(release_pos_z),
    !is.na(release_pos_x),
    !is.na(plate_z),
    !is.na(plate_x),
    !is.na(ax),
    !is.na(az),
    !is.na(pfx_x),
    !is.na(pfx_z)
  )
remove(RHP_FB) # Clean


################################################################################
# TASK 2: Create linear model based on individual pitches
# - Predictor Variables:
#     - stand: if batter is left/right handed (categorical)
#     - strikes: how many strikes the hitter has (categorical)
#     - release_speed: how fast the pitch is
#     - release_extension: how far the release point is from the rubber
#     - release_pos_z: how high the release point is
#     - release_pos_x: how far horizontally the release point is from the center
#     - plate_z: vertical location of the pitch (where it ends)
#     - plate_x: horizontal location of the pitch (where it ends)
#     - az: vertical acceleration of the pitch
#     - ax: horizontal acceleration of the pitch
#     - pfx_x: horizontal movement of the pitch 
#     - pfx_z: vertical movement of the pitch
# - Response Variable:
#     - whiff: percentage of swinging_strike of all swings
# - Interaction terms:
#     - stand : release_pos_x: being on left/right side of the plate affects
#                              the horizontal angle
#     - stand : plate_x: to a left-handed batter, higher plate_x means the pitch
#               location is more relatively inside (opposite for right-handers)
#     - stand : ax: similar to above, horizontal acceleration is relatively
#                   opposite to left-handers


# Fit the linear model to predictor variables
fb_model <- lm(whiff ~ stand + strikes + release_speed + release_extension + 
                 release_pos_z + release_pos_x + plate_z + plate_x + ax + az + 
                 pfx_x + pfx_z +
                 # interaction terms
                 stand:release_pos_x + stand:plate_x + stand:ax
               , 
               data = RHP_FB0)


################################################################################
# TASK 3: Analyze the results from the above linear model
# - Find coefficient of correlation and p-value(s)
# - Perform ANOVA test
# - Perform inflation test
# - 
# - 

# Find basic values --including R^2 (adjusted) and p_value(s)
summary(fb_model)

# comments


# release_pos_x is not statistically significant
# (it also has the smallest coefficient)
# Analysis: because we can see in a wide-angle, having a wider/closer release 
#           point doesn't influence how well the batter can see the ball


# pfx_x is multicollinear with ax
# Analysis: this is because horizontal acceleration causes horizontal movement

# pfx_z is multicollinear with az
# Analysis: this is because vertical acceleration causes vertical movement

# Initially, release_speed had a very high p_value. This was strange because
# it's common knowledge in baseball that high velocity is the most important
# thing in terms of making batters struggle to hit the ball.
# After removing pfx_x and pfx_z, release_speed had very low p_value.
# We hypothesize that those variables were multicollinear with release_speed
# as movement is a function of time; slower pitches have more time to move.

# So, finally, we decided to remove pfx_x and pfx_z, along with
# release_pos_x and stand:release_pos_x



################################################################################
# TASK 4: Update the linear model based on the analyses
# - Remove pfx_x, pfx_z, release_pos_x, stand:release_pos_x


# New linear model
fb_model_updated <- lm(whiff ~ stand + strikes + release_speed + 
                         release_extension + release_pos_z + plate_z + plate_x + 
                         ax + az + stand:plate_x + stand:ax,
                       data = RHP_FB0)

# Brief analysis
summary(fb_model_updated)

# Remove old model
remove(fb_model)


################################################################################
# TASK 5: Apply the linear model to predict pitcher performance (whiff rate)
# - Create a whiff rate prediction for each individual pitch
# - Aggregate the predictions, and the actual results for each pitcher, each year
# - Filter pitchers with too few results
#   (We decided to use count > 50 as that removes all the whiff = 0;
#    In MLB, pitchers regularily throw 1000+ pitches throughout the season.)


# Create whiff rate predictions
Predict_RHP_FB0 <- RHP_FB0 |>
  mutate(est_whiff = predict(fb_model_updated, new_data = RHP_FB0))
remove(RHP_FB0) # Clean
remove(fb_model_updated)

# Aggregate predictions for each pitcher, each year
Final <- Predict_RHP_FB0 |>
  group_by(player_name, game_year) |>
  summarise(count = n(),
            whiff = mean(whiff),
            est_whiff = mean(est_whiff)) |>
  filter(count > 50) # Filter pitchers with too few results (many 0's)
remove(Predict_RHP_FB0) # Clean


################################################################################
# TASK 6: Analyze the final results
# - Use a linear model between prediction and actual to analyze the results
#     - We will use a weighted linear model as some pitchers have thrown
#       more pitches than others
# - Perform ANOVA test???
# - Perform inflation test???
# - Plot
# - 
# - 


# Fit the linear model between prediction and actual
Final_lm_weighted <- lm(whiff ~ est_whiff, data = Final, weights = count)

# Find basic values --including R^2 (adjusted) and p_value(s)
summary(Final_lm_weighted) # R^2: 0.3937  p_value: < 2.2e-16

# Plot 
ggplot(Final, aes(x = est_whiff, y = whiff)) +
  geom_point(color = "blue", alpha = 0.6, size = 2) +  # Adjust color, transparency, and size of points
  geom_abline(intercept = 0, slope = 1, linetype = "solid", color = "black") +  # y = x line for reference
  labs(
    title = "Predicted vs Actual Whiff Rate for Pitchers",
    x = "Estimated Whiff Rate (Predicted)",
    y = "Actual Whiff Rate"
  ) +
  theme_minimal(base_size = 15) +  # Clean theme with larger font size
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),  # Center and bold the title
    axis.title.x = element_text(margin = margin(t = 10)),   # Add spacing around axis titles
    axis.title.y = element_text(margin = margin(r = 10)),
    panel.grid.major = element_line(color = "grey90"),      # Lighten grid lines for cleaner look
    panel.grid.minor = element_blank()                      # Remove minor grid lines
  )



