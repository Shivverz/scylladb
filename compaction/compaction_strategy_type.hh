/*
 * Copyright (C) 2020-present ScyllaDB
 */

/*
 * SPDX-License-Identifier: LicenseRef-ScyllaDB-Source-Available-1.0
 */

#pragma once

#include <cstddef>
#include <cstdint>

namespace sstables {

enum class compaction_strategy_type {
    null = 0,
    size_tiered,
    leveled,
    time_window,
    in_memory,
    incremental,
};

static const char* Compaction_Types[] = {
    "null",
    "size_tiered",
    "leveled",
    "time_window",
    "in_memory",
    "incremental",
};

static_assert(sizeof(sstables::Compaction_Types)/sizeof(char*) == 
              static_cast<size_t>(sstables::compaction_strategy_type::incremental) + 1, 
              "sizes don't match");

enum class reshape_mode { strict, relaxed };

struct reshape_config {
    reshape_mode mode;
    const uint64_t free_storage_space;
};

}
