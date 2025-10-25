import torch
import torch.nn as nn
import pandas as pd
import torch.utils.model_zoo as model_zoo
import torch.onnx
from torch import nn
import onnxscript
import torch.nn.init as init
from sklearn.model_selection import train_test_split
from nn import NeuralNetwork
device = torch.device("cpu")
heart = pd.read_csv("data.csv")
heart=heart.drop(['thal'],axis=1)
#print(heart.head())
#print(heart.columns)
#exit(0)

train, test = train_test_split(heart, test_size=0.1)

trainInputs = train[['age', 'sex', 'cp', 'trestbps', 'chol', 'fbs', 'restecg', 'thalach', 'exang', 'oldpeak', 'slope', 'ca']].values
#print(trainInputs)



trainTargets = train[train.columns[12]].values
#print(trainTargets)



inputs = torch.tensor(trainInputs, dtype=torch.float)
targets = torch.tensor(trainTargets, dtype=torch.long)
#print(targets)

testInputs = torch.tensor(test[['age', 'sex', 'cp', 'trestbps', 'chol', 'fbs', 'restecg', 'thalach', 'exang', 'oldpeak', 'slope', 'ca']].values, dtype=torch.float)
#print(testInputs)
testTarget = torch.tensor(test[test.columns[12]].values, dtype=torch.long)
#print(testTarget)

#print(testInputs.size())

#print(inputs.shape[1])
#exit(0)



model = NeuralNetwork(input_size=inputs.shape[1], hidden_size=256, num_classes=targets.max().item()+1)

model.to(device)
criterion = nn.CrossEntropyLoss()
optimizer = torch.optim.Adam(model.parameters(), lr=0.001)
num_epochs = 10000
model.train(True)
#file_obj = open("writing.txt", "w")

for epoch in range(num_epochs):
    outputs = model(inputs.to(torch.float))
    loss = criterion(outputs, targets)

    print(f"Epoch: {epoch + 1}/{num_epochs}, Loss: {loss.item():.4f}")
    #print(outputs)
    #file_obj.write(f'\n{loss.item():.4f}')

    optimizer.zero_grad()
    loss.backward()
    optimizer.step()

model.train(False)

#prediction
# Step 6: Evaluate the model on the test set
with torch.no_grad():
    probabilities = model(testInputs)
    loss = criterion(probabilities, testTarget)
    print(f'Test set loss: {loss.item():.4f}')

    _, predicted_classes = torch.max(probabilities, dim=1)
    #print(predicted_classes)
    #print(testTarget)

# Export the model
torch.onnx.export(
    model,
    testInputs,
    "heart.onnx",
    export_params=True,
    opset_version=17,
    do_constant_folding=True,
    input_names=['age', 'sex', 'trestbps', 'chol', 'fbs', 'restecg', 'thalach'],
    output_names=['target'],
    dynamic_shapes={'x': {0: 'batch_size'}}
)




x = torch.rand((12, 1), dtype=torch.float)
torch.onnx.export(
    model,
    testInputs,
    "heart.onnx",
    export_params=True,
    opset_version=17,
    do_constant_folding=True,
    input_names=['age', 'sex', 'trestbps', 'chol', 'fbs', 'restecg', 'thalach'],
    output_names=['target'],
    dynamic_shapes={'x': {0: 'batch_size'}}
)





torch.save(model.state_dict(), "heart.model")
#file_obj.close()
