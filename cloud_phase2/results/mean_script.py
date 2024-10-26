import os
import sys
import pandas as pd
import numpy as np

def calculate_mean_from_csv(folder_path):
    # Normalize the folder path (handles both 'run5' and 'run5/')
    folder_path = os.path.normpath(folder_path)
    
    # Get the folder name from the folder path
    folder_name = os.path.basename(folder_path)

    # Generate the output file name and save it inside the folder
    output_file = os.path.join(folder_path, f"{folder_name}_mean.csv")

    # Get all CSV files in the folder and sort them
    csv_files = sorted([f for f in os.listdir(folder_path) if f.endswith('.csv')])

    # List to store dataframes
    dataframes = []

    # Read each CSV file and append it to the list of dataframes
    for file in csv_files:
        file_path = os.path.join(folder_path, file)
        df = pd.read_csv(file_path, header=None)
        dataframes.append(df)

    # Ensure all dataframes have the same shape for averaging
    if not all(df.shape == dataframes[0].shape for df in dataframes):
        print("Error: All CSV files must have the same shape (number of rows and columns).")
        return

    # Stack dataframes along a new third axis and calculate the mean across this axis
    data_array = np.dstack([df.values for df in dataframes])
    mean_array = np.mean(data_array, axis=2)

    # Convert the result back to a DataFrame, round to 2 decimals
    mean_df = pd.DataFrame(mean_array).round(2)

    # Save the result to a new CSV file inside the specified folder
    mean_df.to_csv(output_file, index=False, header=False)

# Main execution
if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script_name.py <folder_name>")
    else:
        folder_name = sys.argv[1]
        calculate_mean_from_csv(folder_name)
