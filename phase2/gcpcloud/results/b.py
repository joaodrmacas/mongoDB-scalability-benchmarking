import csv

# Input data
data = [
    (23480.19, 59.35),
    (23461.65, 60.09),
    (23470.92, 58.43),
    (23461.65, 59.70),
    (41350.29, 68.85),
    (41342.29, 70.72),
    (41308.34, 67.94),
    (41290.38, 69.54),
    (54747.15, 80.15),
    (54747.15, 79.64),
    (54807.69, 79.97),
    (54810.33, 82.81),
    (70912.04, 106.85),
    (70960.94, 103.96),
    (71020.41, 104.70),
    (70978.42, 105.88),
    (83575.33, 143.02),
    (83567.11, 137.41),
    (83575.33, 139.81),
    (83628.76, 138.15),
    (94850.64, 604.36),
    (94931.66, 622.62),
    (94850.64, 605.55),
    (94715.91, 624.76),
    (89941.54, 1310.68),
    (89753.18, 1300.31),
    (89463.22, 1324.66),
    (96330.28, 1157.64),
    (96177.15, 1834.93),
    (96246.57, 1825.76),
    (96001.73, 1833.56),
    (96029.38, 1836.69),
    (91356.54, 2507.66),
    (91102.71, 2532.02),
    (91052.94, 2548.21),
    (90908.10, 2554.36),
]

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

# Prepare data for CSV
output_data = zip(sums_first_column, means_second_column)

# Write to CSV
with open('output.csv', mode='w', newline='') as file:
    writer = csv.writer(file)
    writer.writerow(['Sum of First Column', 'Mean of Second Column'])  # Write header
    writer.writerows(output_data)  # Write data

print("Results have been written to output.csv.")
