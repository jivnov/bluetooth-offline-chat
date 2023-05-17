# Bluetooth Offline Chat

Bluetooth Offline Chat is an iOS app that enables users to engage in chat conversations using the Multipeer Connectivity framework.

## Features

- Chat with other users using Bluetooth connectivity
- Messages are stored in a local database, so users can view their chat history and read old messages
- Ensured app security by implementing passcode and biometric authentication for device locking

## Tech details

- Utilizes the Multipeer Connectivity framework to establish direct Bluetooth connections between devices, enabling real-time chat
- CoreData is to store and manage chat messages within a local database
- Combine framework is used to enable instant updates to the message history
- Enhances security by storing passwords using the Keychain
- Implements Local Authentication to leverage biometric login for enhanced user convenience and security

## Installation

- Clone this repository
- Open the project in Xcode
- Run the app on a physical device or simulator running iOS 14 or higher

## Usage

- Open the app on two devices or simulators
- On both devices, tap the "plus" button
- On any device choose the detected peer
- The devices should automatically establish a Bluetooth connection and a new chat will appear
- Start chatting!

## License

This project is licensed under the MIT License. See the LICENSE file for details.