.PHONY: test-coverage
test-coverage:
	flutter test --coverage
	lcov --remove coverage/lcov.info "**/*.g.dart" "**/*.freezed.dart" -o coverage/lcov_filtered.info --ignore-errors unused
	@echo "Coverage report generated at coverage/lcov_filtered.info"
	@echo "Generated files (.g.dart, .freezed.dart) have been excluded from coverage"

.PHONY: test-coverage-html
test-coverage-html: test-coverage
	genhtml coverage/lcov_filtered.info -o coverage/html
	@echo "HTML coverage report generated at coverage/html/index.html"