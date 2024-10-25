import numpy as np
import pandas as pd

# Function to generate similar CSVs
def generate_similar_csv(data, variation=0.03):
    noise = 1 + np.random.uniform(-variation, variation, data.shape)
    new_data = data * noise
    return pd.DataFrame(new_data, columns=["Value1", "Value2"])

# Function to read CSV and generate similar CSVs
def process_csv(input_file):
    # Read the CSV file
    original_data = pd.read_csv(input_file, header=None)
    
    # Convert to NumPy array
    data_array = original_data.to_numpy()
    
    # Generate two similar CSVs
    csv5 = generate_similar_csv(data_array)
    csv6 = generate_similar_csv(data_array)
    
    # Save the generated CSVs without row numbers and with commas
    csv5.to_csv('similar_csv_1.csv', index=False, header=False)
    csv6.to_csv('similar_csv_2.csv', index=False, header=False)
    
    return csv5, csv6

# Example usage
# Replace 'input_file.csv' with your actual file path
csv5, csv6 = process_csv('./results/run1/run1.1.csv')
print(csv5.to_csv(index=False, header=False))  # Outputs without row numbers
print(csv6.to_csv(index=False, header=False))  # Outputs without row numbers
