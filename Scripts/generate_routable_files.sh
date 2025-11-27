#!/bin/bash

# Generate Route.swift, RoutableTypes.swift, Activity.swift, and Tab.swift by scanning ViewModels
# This script automatically discovers all ViewModels that conform to Routable

set -e

# Configuration
PROJECT_DIR="${SRCROOT}"
ROUTE_OUTPUT="${PROJECT_DIR}/Ios-MVVM/Presentation/Coordinator/Route.swift"
TYPES_OUTPUT="${PROJECT_DIR}/Ios-MVVM/Presentation/Coordinator/RoutableTypes.swift"
ACTIVITY_OUTPUT="${PROJECT_DIR}/Ios-MVVM/Presentation/Coordinator/Activity.swift"
TAB_OUTPUT="${PROJECT_DIR}/Ios-MVVM/Presentation/Coordinator/Tab.swift"
SEARCH_DIR="${PROJECT_DIR}/Ios-MVVM"

echo "🔍 Scanning for Routable types in: ${SEARCH_DIR}"

# Find all ViewModel files that conform to Routable
ROUTABLE_FILES=$(/usr/bin/find "${SEARCH_DIR}" -name "*ViewModel.swift" -type f -exec /usr/bin/grep -l "extension.*:.*Routable" {} \;)

# Extract type names, paths, activities, and tabs
declare -a TYPE_NAMES
declare -a TYPE_PATHS
declare -a TYPE_IDS
declare -a TYPE_ACTIVITIES
declare -a TYPE_TABS
declare -a TYPE_TAB_ICONS
declare -a TYPE_TAB_INDEXES

while IFS= read -r file; do
    if [ -n "$file" ]; then
        # Extract type name
        TYPE_NAME=$(/usr/bin/grep "extension.*:.*Routable" "$file" | /usr/bin/sed -E 's/.*extension[[:space:]]+([A-Za-z0-9_]+)[[:space:]]*:[[:space:]]*Routable.*/\1/')

        # Extract path from routeConfig
        PATH_LINE=$(/usr/bin/grep 'path:' "$file" | /usr/bin/head -1)
        if [[ $PATH_LINE =~ \"([^\"]+)\" ]]; then
            PATH="${BASH_REMATCH[1]}"
        else
            PATH=""
        fi

        # Extract activity from routeConfig
        ACTIVITY_LINE=$(/usr/bin/grep 'activity:' "$file" | /usr/bin/head -1)
        if [[ $ACTIVITY_LINE =~ \.([a-zA-Z0-9_]+) ]]; then
            ACTIVITY="${BASH_REMATCH[1]}"
        else
            ACTIVITY=""
        fi

        # Extract tab configuration from routeConfig (if present)
        # Look for: tab: TabConfig(identifier: "home", icon: "house.fill", index: 0)
        TAB_LINE=$(/usr/bin/grep 'tab:' "$file" | /usr/bin/head -1)

        TAB=""
        TAB_ICON=""
        TAB_INDEX=""

        # Only process if it's not "tab: nil"
        if [[ -n "$TAB_LINE" ]] && [[ ! "$TAB_LINE" =~ "tab: nil" ]]; then
            # Extract identifier
            if [[ "$TAB_LINE" =~ identifier:[[:space:]]*\"([^\"]+)\" ]]; then
                TAB="${BASH_REMATCH[1]}"
            fi

            # Extract icon
            if [[ "$TAB_LINE" =~ icon:[[:space:]]*\"([^\"]+)\" ]]; then
                TAB_ICON="${BASH_REMATCH[1]}"
            fi

            # Extract index
            if [[ "$TAB_LINE" =~ index:[[:space:]]*([0-9]+) ]]; then
                TAB_INDEX="${BASH_REMATCH[1]}"
            fi
        fi

        # Generate route identifier from ViewModel name
        # HomeViewModel -> home, ProductDetailViewModel -> productDetail
        BASE_NAME=$(echo "$TYPE_NAME" | /usr/bin/sed 's/ViewModel$//')
        FIRST_CHAR=$(echo "$BASE_NAME" | /usr/bin/cut -c1 | /usr/bin/tr '[:upper:]' '[:lower:]')
        REST=$(echo "$BASE_NAME" | /usr/bin/cut -c2-)
        ROUTE_ID="${FIRST_CHAR}${REST}"

        if [ -n "$TYPE_NAME" ] && [ -n "$PATH" ] && [ -n "$ACTIVITY" ]; then
            TYPE_NAMES+=("$TYPE_NAME")
            TYPE_PATHS+=("$PATH")
            TYPE_IDS+=("$ROUTE_ID")
            TYPE_ACTIVITIES+=("$ACTIVITY")
            TYPE_TABS+=("$TAB")
            TYPE_TAB_ICONS+=("$TAB_ICON")
            TYPE_TAB_INDEXES+=("$TAB_INDEX")
        fi
    fi
done <<< "$ROUTABLE_FILES"

TYPE_COUNT=${#TYPE_NAMES[@]}
echo "✅ Found ${TYPE_COUNT} Routable types"

# Function to convert snake_case or camelCase to Title Case
function to_title_case() {
    local input="$1"
    # Convert camelCase to spaces: ecommerce -> ecommerce, myApp -> my App
    local spaced=$(echo "$input" | /usr/bin/sed 's/\([a-z]\)\([A-Z]\)/\1 \2/g')
    # Capitalize first letter of each word
    echo "$spaced" | /usr/bin/awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1'
}

# Collect unique activities and tabs
declare -a UNIQUE_ACTIVITIES
declare -a UNIQUE_TABS
declare -a UNIQUE_TAB_ICONS
declare -a UNIQUE_TAB_INDEXES
declare -a TAB_ACTIVITY_MAPPING
declare -a ACTIVITY_DEFAULT_TAB_MAPPING

# Helper function to check if value exists in array
function contains() {
    local value="$1"
    shift
    for item in "$@"; do
        if [ "$item" = "$value" ]; then
            return 0
        fi
    done
    return 1
}

# Helper function to get activity for tab
function get_activity_for_tab() {
    local search_tab="$1"
    for i in "${!UNIQUE_TABS[@]}"; do
        if [ "${UNIQUE_TABS[$i]}" = "$search_tab" ]; then
            echo "${TAB_ACTIVITY_MAPPING[$i]}"
            return
        fi
    done
}

# Helper function to get default tab for activity
function get_default_tab_for_activity() {
    local search_activity="$1"
    for i in "${!UNIQUE_ACTIVITIES[@]}"; do
        if [ "${UNIQUE_ACTIVITIES[$i]}" = "$search_activity" ]; then
            echo "${ACTIVITY_DEFAULT_TAB_MAPPING[$i]}"
            return
        fi
    done
}

for i in "${!TYPE_NAMES[@]}"; do
    ACTIVITY="${TYPE_ACTIVITIES[$i]}"
    TAB="${TYPE_TABS[$i]}"
    TAB_ICON="${TYPE_TAB_ICONS[$i]}"
    TAB_INDEX="${TYPE_TAB_INDEXES[$i]}"
    ROUTE_ID="${TYPE_IDS[$i]}"

    # Track unique activities
    if ! contains "$ACTIVITY" "${UNIQUE_ACTIVITIES[@]}"; then
        UNIQUE_ACTIVITIES+=("$ACTIVITY")
        ACTIVITY_DEFAULT_TAB_MAPPING+=("")  # Will be set when first tab is found
    fi

    # Track tabs and their activities
    if [ -n "$TAB" ]; then
        if ! contains "$TAB" "${UNIQUE_TABS[@]}"; then
            UNIQUE_TABS+=("$TAB")
            UNIQUE_TAB_ICONS+=("$TAB_ICON")
            UNIQUE_TAB_INDEXES+=("$TAB_INDEX")
            TAB_ACTIVITY_MAPPING+=("$ACTIVITY")
        fi

        # Set default tab for activity
        # Prioritize "home" tab, otherwise use the first tab encountered (lowest index)
        for j in "${!UNIQUE_ACTIVITIES[@]}"; do
            if [ "${UNIQUE_ACTIVITIES[$j]}" = "$ACTIVITY" ]; then
                if [ -z "${ACTIVITY_DEFAULT_TAB_MAPPING[$j]}" ]; then
                    # No default yet, set this tab
                    ACTIVITY_DEFAULT_TAB_MAPPING[$j]="$TAB"
                elif [ "$TAB" = "home" ]; then
                    # Override with "home" if we find it
                    ACTIVITY_DEFAULT_TAB_MAPPING[$j]="$TAB"
                fi
                break
            fi
        done
    fi
done

ACTIVITY_COUNT=${#UNIQUE_ACTIVITIES[@]}
TAB_COUNT=${#UNIQUE_TABS[@]}
echo "✅ Found ${ACTIVITY_COUNT} unique activities"
echo "✅ Found ${TAB_COUNT} unique tabs"

# Sort tabs by index
# Create array of "index:tab:icon:activity" strings, sort by index, then split back
declare -a SORTED_TAB_DATA
for i in "${!UNIQUE_TABS[@]}"; do
    TAB="${UNIQUE_TABS[$i]}"
    ICON="${UNIQUE_TAB_ICONS[$i]}"
    INDEX="${UNIQUE_TAB_INDEXES[$i]}"
    ACTIVITY="${TAB_ACTIVITY_MAPPING[$i]}"
    SORTED_TAB_DATA+=("${INDEX}:${TAB}:${ICON}:${ACTIVITY}")
done

# Sort by index (first field)
IFS=$'\n' SORTED_TAB_DATA=($(/usr/bin/sort -t: -k1 -n <<<"${SORTED_TAB_DATA[*]}"))
unset IFS

# Split back into separate arrays
UNIQUE_TABS=()
UNIQUE_TAB_ICONS=()
UNIQUE_TAB_INDEXES=()
TAB_ACTIVITY_MAPPING=()

for data in "${SORTED_TAB_DATA[@]}"; do
    IFS=':' read -r INDEX TAB ICON ACTIVITY <<< "$data"
    UNIQUE_TAB_INDEXES+=("$INDEX")
    UNIQUE_TABS+=("$TAB")
    UNIQUE_TAB_ICONS+=("$ICON")
    TAB_ACTIVITY_MAPPING+=("$ACTIVITY")
done

# Generate Activity.swift
/bin/cat > "${ACTIVITY_OUTPUT}" << 'EOF'
//
//  Activity.swift
//  Ios-MVVM
//
//  🤖 AUTO-GENERATED FILE - DO NOT EDIT MANUALLY
//  Generated by Scripts/generate_routable_files.sh
//  Activities are derived from ViewModel routeConfigs
//

import Foundation

enum Activity: String, Codable, CaseIterable {
EOF

# Add activity cases
for ACTIVITY in "${UNIQUE_ACTIVITIES[@]}"; do
    /bin/echo "    case ${ACTIVITY}" >> "${ACTIVITY_OUTPUT}"
done

# Add displayName property
/bin/cat >> "${ACTIVITY_OUTPUT}" << 'EOF'

    var displayName: String {
        switch self {
EOF

for ACTIVITY in "${UNIQUE_ACTIVITIES[@]}"; do
    DISPLAY_NAME=$(to_title_case "$ACTIVITY")
    /bin/echo "        case .${ACTIVITY}:" >> "${ACTIVITY_OUTPUT}"
    /bin/echo "            return \"${DISPLAY_NAME}\"" >> "${ACTIVITY_OUTPUT}"
done

/bin/cat >> "${ACTIVITY_OUTPUT}" << 'EOF'
        }
    }

    var defaultTab: Tab {
        switch self {
EOF

# Add defaultTab property
for i in "${!UNIQUE_ACTIVITIES[@]}"; do
    ACTIVITY="${UNIQUE_ACTIVITIES[$i]}"
    DEFAULT_TAB="${ACTIVITY_DEFAULT_TAB_MAPPING[$i]}"
    if [ -n "$DEFAULT_TAB" ]; then
        /bin/echo "        case .${ACTIVITY}:" >> "${ACTIVITY_OUTPUT}"
        /bin/echo "            return .${DEFAULT_TAB}" >> "${ACTIVITY_OUTPUT}"
    fi
done

/bin/cat >> "${ACTIVITY_OUTPUT}" << 'EOF'
        }
    }
}
EOF

echo "✅ Generated Activity.swift with ${ACTIVITY_COUNT} activities"

# Generate Tab.swift
/bin/cat > "${TAB_OUTPUT}" << 'EOF'
//
//  Tab.swift
//  Ios-MVVM
//
//  🤖 AUTO-GENERATED FILE - DO NOT EDIT MANUALLY
//  Generated by Scripts/generate_routable_files.sh
//  Tabs are derived from ViewModel routeConfigs
//

import SwiftUI

enum Tab: String, CaseIterable {
EOF

# Add tab cases
for TAB in "${UNIQUE_TABS[@]}"; do
    /bin/echo "    case ${TAB}" >> "${TAB_OUTPUT}"
done

# Add title property
/bin/cat >> "${TAB_OUTPUT}" << 'EOF'

    var title: String {
        switch self {
EOF

for i in "${!UNIQUE_TABS[@]}"; do
    TAB="${UNIQUE_TABS[$i]}"
    TITLE=$(to_title_case "$TAB")
    /bin/echo "        case .${TAB}:" >> "${TAB_OUTPUT}"
    /bin/echo "            return \"${TITLE}\"" >> "${TAB_OUTPUT}"
done

/bin/cat >> "${TAB_OUTPUT}" << 'EOF'
        }
    }

    var icon: String {
        switch self {
EOF

# Add icon property
for i in "${!UNIQUE_TABS[@]}"; do
    TAB="${UNIQUE_TABS[$i]}"
    ICON="${UNIQUE_TAB_ICONS[$i]}"
    /bin/echo "        case .${TAB}:" >> "${TAB_OUTPUT}"
    /bin/echo "            return \"${ICON}\"" >> "${TAB_OUTPUT}"
done

/bin/cat >> "${TAB_OUTPUT}" << 'EOF'
        }
    }

    var activity: Activity {
        switch self {
EOF

# Add activity mapping
for i in "${!UNIQUE_TABS[@]}"; do
    TAB="${UNIQUE_TABS[$i]}"
    ACTIVITY="${TAB_ACTIVITY_MAPPING[$i]}"
    /bin/echo "        case .${TAB}:" >> "${TAB_OUTPUT}"
    /bin/echo "            return .${ACTIVITY}" >> "${TAB_OUTPUT}"
done

/bin/cat >> "${TAB_OUTPUT}" << 'EOF'
        }
    }

    var rootRoute: Route {
        switch self {
EOF

# Add rootRoute mapping
for TAB in "${UNIQUE_TABS[@]}"; do
    # Find the route ID for this tab by looking for ViewModels with this tab
    for i in "${!TYPE_TABS[@]}"; do
        if [ "${TYPE_TABS[$i]}" = "$TAB" ]; then
            ROUTE_ID="${TYPE_IDS[$i]}"
            /bin/echo "        case .${TAB}:" >> "${TAB_OUTPUT}"
            /bin/echo "            return .${ROUTE_ID}" >> "${TAB_OUTPUT}"
            break
        fi
    done
done

/bin/cat >> "${TAB_OUTPUT}" << 'EOF'
        }
    }

    static func tabs(for activity: Activity) -> [Tab] {
        allCases.filter { $0.activity == activity }
    }
}
EOF

echo "✅ Generated Tab.swift with ${TAB_COUNT} tabs"

# Generate Route.swift
/bin/cat > "${ROUTE_OUTPUT}" << 'EOF'
//
//  Route.swift
//  Ios-MVVM
//
//  🤖 AUTO-GENERATED FILE - DO NOT EDIT MANUALLY
//  Generated by Scripts/generate_routable_files.sh
//  Routes are derived from ViewModel paths
//

import Foundation

enum Route: Hashable {
EOF

# Add route cases
for i in "${!TYPE_NAMES[@]}"; do
    TYPE="${TYPE_NAMES[$i]}"
    PATH="${TYPE_PATHS[$i]}"
    ROUTE_ID="${TYPE_IDS[$i]}"

    # Check if path has parameters (contains :)
    if [[ $PATH == *":"* ]]; then
        # Extract model type from ViewModel name (e.g., ProductDetailViewModel -> Product)
        MODEL=$(echo "$TYPE" | /usr/bin/sed 's/DetailViewModel//' | /usr/bin/sed 's/ViewModel//')
        /bin/echo "    case ${ROUTE_ID}(${MODEL})" >> "${ROUTE_OUTPUT}"
    else
        /bin/echo "    case ${ROUTE_ID}" >> "${ROUTE_OUTPUT}"
    fi
done

# Add identifier property
/bin/cat >> "${ROUTE_OUTPUT}" << 'EOF'

    var identifier: String {
        Mirror(reflecting: self).children.first?.label ?? String(describing: self)
    }
}
EOF

echo "✅ Generated Route.swift with ${TYPE_COUNT} routes"

# Generate RoutableTypes.swift
/bin/cat > "${TYPES_OUTPUT}" << 'EOF'
//
//  RoutableTypes.swift
//  Ios-MVVM
//
//  🤖 AUTO-GENERATED FILE - DO NOT EDIT MANUALLY
//  Generated by Scripts/generate_routable_files.sh
//  Generated at compile time - should be in .gitignore
//

import Foundation

/// Auto-generated list of all routable view model types
@MainActor
let routableTypes: [any Routable.Type] = [
EOF

# Add each type to the array
for TYPE in "${TYPE_NAMES[@]}"; do
    /bin/echo "    ${TYPE}.self," >> "${TYPES_OUTPUT}"
done

/bin/cat >> "${TYPES_OUTPUT}" << 'EOF'
]

/// Maps route identifiers to their corresponding ViewModel types
@MainActor
let routableTypeMap: [String: any Routable.Type] = [
EOF

# Add mappings
for i in "${!TYPE_NAMES[@]}"; do
    TYPE="${TYPE_NAMES[$i]}"
    ROUTE_ID="${TYPE_IDS[$i]}"
    /bin/echo "    \"${ROUTE_ID}\": ${TYPE}.self," >> "${TYPES_OUTPUT}"
done

/bin/cat >> "${TYPES_OUTPUT}" << 'EOF'
]
EOF

echo "✅ Generated RoutableTypes.swift with ${TYPE_COUNT} types"
echo ""
echo "📝 Summary:"
echo "   Activities: ${ACTIVITY_COUNT}"
for i in "${!UNIQUE_ACTIVITIES[@]}"; do
    ACTIVITY="${UNIQUE_ACTIVITIES[$i]}"
    DISPLAY_NAME=$(to_title_case "$ACTIVITY")
    DEFAULT_TAB="${ACTIVITY_DEFAULT_TAB_MAPPING[$i]}"
    /bin/echo "     - ${ACTIVITY} (${DISPLAY_NAME}) [default tab: ${DEFAULT_TAB}]"
done
echo ""
echo "   Tabs: ${TAB_COUNT}"
for i in "${!UNIQUE_TABS[@]}"; do
    TAB="${UNIQUE_TABS[$i]}"
    TITLE=$(to_title_case "$TAB")
    ACTIVITY="${TAB_ACTIVITY_MAPPING[$i]}"
    /bin/echo "     - ${TAB} (${TITLE}) [activity: ${ACTIVITY}]"
done
echo ""
echo "   Routes: ${TYPE_COUNT}"
for i in "${!TYPE_NAMES[@]}"; do
    /bin/echo "     - ${TYPE_NAMES[$i]} (${TYPE_PATHS[$i]})"
done
