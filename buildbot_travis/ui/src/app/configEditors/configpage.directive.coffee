class ConfigPage extends Directive
    constructor: ->
        return {
            replace: true
            transclude: true
            restrict: 'E' # E: Element
            templateUrl: 'buildbot_travis/views/config_page.html'
            controller: '_ConfigPageController'
        }


class _ConfigPage extends Controller
    self = null
    constructor: (@$scope, config, $state, $http) ->
        self = this
        @$scope.cfg = angular.copy(config.plugins.buildbot_travis.cfg)
        @$scope.buildbot_travis = config.plugins.buildbot_travis
        @$scope.errors = []
        @$scope.saving = false
        for p in @$scope.cfg.projects
            if p.branch
                p.branches = p.branch.split(" ")
                delete p.branch
        @$scope.save = ->
            self.$scope.$broadcast('show-errors-check-validity')
            if not self.$scope.hasInvalids()
                config.plugins.buildbot_travis.cfg
                config.plugins.buildbot_travis.cfg = angular.copy(self.$scope.cfg)
                self.$scope.saving = true
                $http.put("buildbot_travis/api/config", config.plugins.buildbot_travis.cfg).then (res) ->
                    if res.data.success
                        location.reload(true)  # reload the application to take in account new builders
                    else
                        self.$scope.saving = false
                        self.$scope.errors = res.data.errors


        @$scope.cancel = ->
            @$scope.cfg = angular.copy(config.plugins.buildbot_travis.cfg)

        @$scope.hasInvalids = ->
            hasInvalidInScope = (scope) ->
                if scope.form?.$invalid
                    return true
                cs = scope.$$childHead
                while cs
                    if hasInvalidInScope(cs)
                        return true
                    cs = cs.$$nextSibling
                return false
            ret = hasInvalidInScope(self.$scope)
            return ret
