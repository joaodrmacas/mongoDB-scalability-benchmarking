import os
import sys
import pandas as pd

def calculate_mean_from_csv(folder_path):
    # Normalize the folder path (handles both 'run5' and 'run5/')
    folder_path = os.path.normpath(folder_path)
    
    # Get the folder name from the folder path
    folder_name = os.path.basename(folder_path)

    # Generate the output file name and save it inside the folder
    output_file = os.path.join(folder_path, f"{folder_name}_mean.csv")

    # Get all CSV files in the folder
    csv_files = [f for f in os.listdir(folder_path) if f.endswith('.csv')]

    # List to store dataframes
    dataframes = []

    # Read each CSV file and append it to the list of dataframes
    for file in csv_files:
        file_path = os.path.join(folder_path, file)
        df = pd.read_csv(file_path, header=None)
        dataframes.append(df)

    # Concatenate all dataframes along the rows
    concatenated_df = pd.concat(dataframes, axis=0)

    # Group by the index to calculate the mean for each row across all files
    mean_df = concatenated_df.groupby(concatenated_df.index).mean()

    # Round the mean values to 3 decimal places
    mean_df = mean_df.round(3)

    # Save the result to a new CSV file inside the specified folder
    mean_df.to_csv(output_file, index=False, header=False)

# Main execution
if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script_name.py <folder_name>")
    else:
        folder_name = sys.argv[1]
        calculate_mean_from_csv(folder_name)
