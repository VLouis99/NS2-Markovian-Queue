import numpy as np
import matplotlib.pyplot as plt

# Parameters
b_values = np.linspace(100, 270, 100)  # Range of arrival rates b (lambda) in kbits from 200 to 260
p1 = 0.25  # Probability of taking the top route
p2 = 0.75  # Probability of taking the bottom route
mu1 = 100  # Service rate for the top route (100 kbits/s)
mu2 = 200  # Service rate for the bottom route (200 kbits/s)

# Calculate the effective service rate based on weighted probabilities
mu_eff = (p1 *mu1 + p2 * mu2)

# Calculate average delay for each b using the M/M/1 formula
delays = []
for b in b_values:
    lambda_ = b
    rho = lambda_ / mu_eff  # Utilization factor
    if rho < 1:
        R = 1 / (mu_eff - lambda_) 
        delays.append(R)
    else:
        delays.append(float('inf'))


print(delays)
# Plotting the results
plt.figure(figsize=(10, 6))
plt.plot(b_values, delays, marker='o', linestyle='-', color='blue')
plt.title('Average Delay R as a function of arrival rate b in M/M/1 Model')
plt.xlabel('Arrival rate b (lambda) in kbits/s')
plt.ylabel('Average Delay R (seconds)')
plt.grid(True)
plt.show()

