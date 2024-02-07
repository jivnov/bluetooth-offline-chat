Bluetooth Chat is an iOS app that allows users to engage in chat conversations using the Firebase messaging and Multipeer Connectivity framework.

## Features

- Dark mode support
- Chat with other users online or using Bluetooth/Local Network connectivity.
- Messages are stored in a local database, allowing users to view their chat history and read old messages. The database automatically synchronizes after returning online.
- Ensured app security by implementing passcode and biometric authentication for device locking.

## Tech details

- Fully SwiftUI
- Utilizes the Firebase and Multipeer Connectivity framework to establish direct connections between devices, enabling real-time chat.
- Uses Firestore to store and manage chat messages within a local database.
- The Combine framework is used to enable instant updates of the message history.
- Enhances security by storing passwords using the Keychain.
- Implements Local Authentication to leverage biometric login for enhanced user convenience and security.

## Installation

- Clone this repository.
- Open the project in Xcode.
- Run the app on a physical device or simulator running iOS 16 or higher.

## Usage

- Login or create an account with any email.
- Enable or disable offline mode in the settings.
- Choose a chat and start chatting!

## License

This project is licensed under the MIT License. See the LICENSE file for details.
