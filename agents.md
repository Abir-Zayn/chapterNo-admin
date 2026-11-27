Divide the feature codebase into the following structure:

feat/
--- domain/
    -- entities/
    -- repositories/
    -- usecase/
--- data/
    -- models/
    -- repositories/
    -- resource/
--- screens/
    -- bloc/
    -- widget/
-- types/
-- utils/

keep the important files has 2 stats
 app_file_name.dart and app_file_name_imports.dart 

Refactoring & placement rules:
- Place all feature enums in `types/`.
- Keep `screens/` focused on page composition; move state/Cubits/Blocs into `screens/bloc/`, reusable UI components into `screens/widgets/`, and validators, formatters, and pure-Dart payload/response helpers (e.g., GraphQL parsing/archive helpers) into `utils/`.

Keep the design mobile friendly. 