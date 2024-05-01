import numpy as np

# Constants
mu = 256  # service rate in kbits per second
K = 100   # capacity of the queue
packet_size_kbits = 8.192  # Packet size in kbits

# List of lambdas in packets per second
lambda_packets_per_second = [5, 10, 15, 20, 25, 28, 30, 31, 32, 33, 34, 35]

# File to save the results
filename = "theoretical_MM1K.dat"

# Function to calculate M/M/1/K Values
def mm1k_metrics(lambd, mu, K):
    rho = lambd / mu
    P0 = (1 - rho) / (1 - rho**(K + 1)) if rho < 1 else 1 / (K + 1)
    
    PK = rho**K * P0
    X = lambd * (1 - PK) if rho < 1 else mu  # Cap X at service rate mu when sys is at full capacity
    Q = (rho / (1 - rho)) - ((K + 1) * rho**(K + 1)) / (1 - rho**(K + 1)) if rho < 1 else K
    R = Q / X if X > 0 else float('inf') 
    return X, R, Q

# Writing results to file
with open(filename, 'w') as f:
    f.write("Lambda\tThroughput(X)\tResponseTime(R)\tQueueLength(Q)\n")
    for lambd_p in lambda_packets_per_second:
        lambd_k = lambd_p * packet_size_kbits  # Convert lambda to kbits per second
        X, R, Q = mm1k_metrics(lambd_k, mu, K)
        f.write(f"{lambd_p}\t{X:.2f}\t{R:.4f}\t{Q:.2f}\n")

print(f"Data has been written to {filename}")

