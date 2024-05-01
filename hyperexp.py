import numpy as np
import matplotlib.pyplot as plt

# Parameters
b_values = np.linspace(100, 265, 100) 
p1 = 0.25  
p2 = 0.75 
mu1 = 100  # Service rate for the top route
mu2 = 200  # Service rate for the bottom route

# Calculate average delay for each b using the two M/M/1 models
delays = []
for b in b_values:
    lambda_1 = p1 * b  # Arrival rate for the first queue
    lambda_2 = p2 * b  # Arrival rate for the second queue

    if lambda_1 < mu1 and lambda_2 < mu2:
        R1 = 1 / (mu1 - lambda_1)  # Delay for the first M/M/1 system
        R2 = 1 / (mu2 - lambda_2)  # Delay for the second M/M/1 system
        R_total = p1 * R1 + p2 * R2  # Weighted sum of the delays
        delays.append(R_total)
    else:
        delays.append(float('inf'))  # System becomes unstable if any lambda >= mu

# Plotting the results
plt.figure(figsize=(10, 6))
plt.plot(b_values, np.array(delays)*10, marker='o', linestyle='-', color='blue')
plt.title('Combined Average Delay R')
plt.xlabel('Arrival rate b (lambda) in kbits/s')
plt.ylabel('Combined Average Delay R (seconds)')
plt.grid(True)
plt.show()

