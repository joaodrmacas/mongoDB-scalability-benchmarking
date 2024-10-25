import csv

# Read input data from a CSV file
input_file = 'input.csv'  # Input CSV file with two columns, no header
data = []

with open(input_file, mode='r') as file:
    reader = csv.reader(file)
    for row in reader:
        # Convert each value to float and append as a tuple
        data.append((float(row[0]), float(row[1])))

# Initialize sums and counts
sums_first_column = []
means_second_column = []
current_sum = 0
count = 0

# Iterate through the data
for i, (first, second) in enumerate(data):
    current_sum += first
    count += 1
    
    # If we have summed 4 values
    if (i + 1) % 4 == 0:
        sums_first_column.append(round(current_sum, 3))
        means_second_column.append(round(sum(second for _, second in data[i-3:i+1]) / 4, 3))
        current_sum = 0

# Prepare data for output CSV
output_data = zip(sums_first_column, means_second_column)

# Write to output CSV
with open('output.csv', mode='w', newline='') as file:
    writer = csv.writer(file)
    writer.writerow(['Sum of First Column', 'Mean of Second Column'])  # Write header
    writer.writerows(output_data)  # Write data

print("Results have been written to output.csv.")
