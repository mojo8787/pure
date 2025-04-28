#!/bin/bash

echo "Running build_runner for code generation..."
flutter pub run build_runner build --delete-conflicting-outputs

if [ $? -eq 0 ]; then
  echo "Code generation completed successfully!"
else
  echo "Error: Code generation failed."
  exit 1
fi 