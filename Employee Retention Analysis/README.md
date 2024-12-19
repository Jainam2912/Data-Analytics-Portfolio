**Project Title**: Employee Attrition Prediction

**Overview:**
This project predicts employee attrition using machine learning models. By analyzing various factors such as job satisfaction level, number of projects worked, salary, time spend in the company, promotion in last 5 years, and avg. monthly hours worked, the model identifies employees at risk of leaving, enabling companies to take proactive measures.

**Key Features of the Project**
1. Exploratory Data Analysis (EDA) for understanding key factors influencing attrition
2. Data preprocessing for handling missing values, encoding categorical data, and feature scaling
3. Machine Learning Models include Logistic Regression, Random Forest, and Deep Learning Sequential Model
4. Evaluation Metrics: Accuracy, Precision, Recall, F-1 score

**Dataset**
The dataset used for this project is synthetic and simulates employee data, including parameters like:
1. Number of Projects Worked
2. Avg. monthly hours worked
3. Time spent at the company (years)
4. Work accidents (if any)
5. Promotion in last 5 years
6. Department of the employee
7. Salary of the employee (low, medium, high)
8. Satisfaction level
9. Last Evaluation

**Key Outcomes**
The parameters that influenced the attrition rates the most were satisfaction level, work accidents, and time spent at the company. Other parameters such as salary could have also affected the attrition rates, however, salary is a categorical column in the data set so could not model the coorelation

Model Performance:
1. **Logistic Regression**
     Accuracy: 79.78%
2. **Random Forest Classifier**
     Accuracy: 98.87%
3. **Deep Learning Sequential Model**
     Accuracy: 95.33% with 1 hidden layer, batch size of 10, and 25 epochs

