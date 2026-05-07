# Bank Customer Feature Engineering with SQL

SQL project focused on creating a denormalized customer-level feature table for future supervised machine learning models in a banking context.

## Project overview

The goal of this project is to transform normalized banking data into a single customer-level table containing behavioral indicators derived from accounts and transactions.

## Objectives

- Join multiple relational database tables
- Calculate customer-level behavioral indicators
- Aggregate transaction counts and amounts
- Create account-type based features
- Build a denormalized table suitable for machine learning

## Features created

- Customer age
- Number of incoming and outgoing transactions
- Total incoming and outgoing transaction amounts
- Total number of accounts
- Number of accounts by account type
- Transaction indicators by account type

## Technologies used

- SQL
- Relational databases
- Joins
- Aggregations
- Feature engineering

## Business value

The resulting feature table can support machine learning models for customer behavior prediction, churn analysis, risk management, personalized offers, and fraud detection.
