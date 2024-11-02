# Load necessary libraries
library(baseballr)
library(dplyr)

# Initialize start and end dates for each year
start_date <- as.Date("2015-01-01")
date_1 <- as.Date("2016-01-01")
date_2 <- as.Date("2017-01-01")
date_3 <- as.Date("2018-01-01")
date_4 <- as.Date("2019-01-01")
date_5 <- as.Date("2020-01-01")
date_6 <- as.Date("2021-01-01")
date_7 <- as.Date("2022-01-01")
date_8 <- as.Date("2023-01-01")
date_9 <- as.Date("2024-01-01")
end_date <- as.Date("2024-10-01")

# Define a list of year start dates and corresponding year names
year_starts <- list(start_date, date_1, date_2, date_3, date_4, date_5, date_6, date_7, date_8, date_9)
year_names <- c("2015", "2016", "2017", "2018", "2019", "2020", "2021", "2022", "2023", "2024")

# Loop through each year and save data as .csv for each year
for (i in 1:length(year_starts)) {
  
  # Initialize data frame for the current year
  year_data <- data.frame()
  current_start <- year_starts[[i]]
  current_end_year <- ifelse(i < length(year_starts), year_starts[[i + 1]] - 1, end_date)
  
  # Loop through each 5-day interval within the year
  while (current_start <= current_end_year) {
    
    # Define the end date for the 5-day interval
    current_end <- min(current_start + 4, current_end_year)
    
    # Fetch data for the current 5-day interval
    tryCatch({
      Data <- baseballr::statcast_search_pitchers(start_date = as.character(current_start), 
                                                  end_date = as.character(current_end))
      
      # Check if Data is empty
      if (nrow(Data) > 0) {
        # Append the new data to year_data only if Data is not empty
        year_data <- bind_rows(year_data, Data)
        message(paste("Fetched data from", current_start, "to", current_end, "for year", year_names[i]))
      } else {
        message(paste("No data found from", current_start, "to", current_end, "for year", year_names[i]))
      }
      
    }, error = function(e) {
      message(paste("Error fetching data from", current_start, "to", current_end, "for year", year_names[i], ":", e))
    })
    
    # Move to the next 5-day interval
    current_start <- current_start + 5
  }
  
  # Save the collected data for the year as a .csv file
  write.csv(year_data, paste0("savant_data_", year_names[i], ".csv"), row.names = FALSE)
  message(paste("Saved data for year", year_names[i], "to savant_data_", year_names[i], ".csv"))
}

message("Data collection and saving completed for all specified years.")
