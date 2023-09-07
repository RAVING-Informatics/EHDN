//
// ExpansionHunter Denovo
// Copyright 2016-2019 Illumina, Inc.
// All rights reserved.
//
// Author: Egor Dolzhenko <edolzhenko@illumina.com>,
//         Michael Eberle <meberle@illumina.com>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//

#pragma once

#include <cstdint>
#include <iostream>
#include <string>
#include <unordered_map>
#include <utility>
#include <vector>

// Handles translation between contig names and indexes
class ReferenceContigInfo
{
public:
    explicit ReferenceContigInfo(std::vector<std::pair<std::string, int64_t>> namesAndSizes);

    int numContigs() const { return namesAndSizes_.size(); }
    const std::string& getContigName(int contigIndex) const;
    int64_t getContigSize(int contigIndex) const;
    int getContigId(const std::string& contigName) const;

private:
    void assertValidIndex(int contigIndex) const;

    std::vector<std::pair<std::string, int64_t>> namesAndSizes_;
    std::unordered_map<std::string, int> nameToIndex_;
};

std::ostream& operator<<(std::ostream& out, const ReferenceContigInfo& contigInfo);
